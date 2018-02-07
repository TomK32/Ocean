<?php

/*
 * 微信支付 (lumen框架)
 * */

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;


class orderscontroller extends controller
{

    //入口函数
    function wechatpay(request $request){
        header('access-control-allow-origin: *');
        header('access-control-allow-methods: post');
        header('access-control-max-age: 1000');

        $order_sn = $request->input('order_sn');

        //根据订单id查找该订单是否支付成功
        if(strlen($order_sn) == 19) {
            $order_info = db::table('order_info')->where('order_sn',$order_sn)->first();
            if ($order_info->pay_status == 0) {
                $json = array();
                //生成预支付交易单的必选参数:
                $newpara = array();
                //应用id
                $newpara["appid"] = "wx751336ae9909617e";
                //商户号
                $newpara["mch_id"] = "1494096322";
                //设备号
                $newpara["device_info"] = "web";
                //随机字符串,这里推荐使用函数生成
                $newpara["nonce_str"] = $this->createnoncestr();

                //商户订单号,这里是商户自己的内部的订单号
                $newpara["out_trade_no"] = $order_sn;

                //根据order_sn获取order_id 然后根据order_id查找order_goods表获取goods_name 和价格
                $order_info = db::table('order_info')->where('order_sn',$order_sn)->first();
                $order_id = $order_info->order_id;

                $order_goods = db::table('order_goods')->where('order_id',$order_id)->first();

                //商品描述
                $newpara["body"] = $order_goods->goods_name;

                //总金额
                $newpara["total_fee"] = ($order_info->goods_amount)*100;
                //终端ip
                $newpara["spbill_create_ip"] = $_server["remote_addr"];
                //通知地址，注意，这里的url里面不要加参数
                $newpara["notify_url"] = "http://api.xmeiz.cn/v1/orders/wx_notify";
                //交易类型
                $newpara["trade_type"] = "app";
                //第一次签名
                $newpara["sign"] = $this->producewechatsign($newpara);

                //把数组转化成xml格式
                $xmldata = $this->getwechatxml($newpara);

                //利用php的curl包，将数据传给微信统一下单接口，返回正常的prepay_id
                $get_data = $this->sendprepaycurl($xmldata);
                //返回的结果进行判断。
                if ($get_data['return_code'] == "success" && $get_data['result_code'] == "success") {
                    //根据微信支付返回的结果进行二次签名
                    //二次签名所需的随机字符串
                    $newpara["nonce_str"] = $this->createnoncestr();
                    //二次签名所需的时间戳
                    $newpara['timestamp'] = time() . "";
                    //二次签名剩余参数的补充
                    $secondsignarray = array(
                        "appid" => $newpara['appid'],
                        "noncestr" => $newpara['nonce_str'],
                        "package" => "sign=wxpay",
                        "prepayid" => $get_data['prepay_id'],
                        "partnerid" => $newpara['mch_id'],
                        "timestamp" => $newpara['timestamp'],
                    );
                    $json['datas'] = $secondsignarray;
                    $json['ordersn'] = $newpara["out_trade_no"];
                    $json['datas']['sign'] = $this->wechatsecondsign($newpara, $get_data['prepay_id']);
                    $json['message'] = "预支付完成";
                    //预支付完成,在下方进行自己内部的业务逻辑
                    /*****************************/
                    return json_encode($json);
                } else {
                    $json['message'] = $get_data['return_msg'];
                }
            }elseif($order_info->pay_status == 1){
                $json = output_error('该订单正在支付中,请勿重复支付');
            }elseif($order_info->pay_status == 2){
                $json = output_error('该订单已支付完成');
            }
        }else{
            $json = output_error('订单号错误');
        }
//        return json_encode($json);
        return response()->json($json);
    }

    //第一次签名的函数producewechatsign
    function producewechatsign($newpara){
        $stringa = self::getsigncontent($newpara);
        $stringsigntemp=$stringa."&key=db0db20f5a963d1bd90c27e644cbf812";
        return strtoupper(md5($stringsigntemp));
    }

    //生成xml格式的函数
    public static function getwechatxml($newpara){
        $xmldata = "<xml>";
        foreach ($newpara as $key => $value) {
            $xmldata = $xmldata."<".$key.">".$value."</".$key.">";
        }
        $xmldata = $xmldata."</xml>";
        return $xmldata;
    }

    //通过curl发送数据给微信接口的函数
    function sendprepaycurl($xmldata) {
        $url = "https://api.mch.weixin.qq.com/pay/unifiedorder";
        $header[] = "content-type: text/xml";
        $curl = curl_init();
        curl_setopt($curl, curlopt_httpheader, $header);
        curl_setopt($curl, curlopt_url, $url);
        curl_setopt($curl, curlopt_returntransfer, true);
        curl_setopt($curl, curlopt_post, 1);
        curl_setopt($curl, curlopt_postfields, $xmldata);
        $data = curl_exec($curl);
        if (curl_errno($curl)) {
            print curl_error($curl);
        }
        curl_close($curl);
        return self::xmldataparse($data);
    }

    //xml格式数据解析函数
    public static function xmldataparse($data){
        $msg = array();
        $msg = (array)simplexml_load_string($data, 'simplexmlelement', libxml_nocdata);
        return $msg;
    }

    //二次签名的函数
    function wechatsecondsign($newpara,$prepay_id){
        $secondsignarray = array(
            "appid"=>$newpara['appid'],
            "noncestr"=>$newpara['nonce_str'],
            "package"=>"sign=wxpay",
            "prepayid"=>$prepay_id,
            "partnerid"=>$newpara['mch_id'],
            "timestamp"=>$newpara['timestamp'],
        );
        $stringa = self::getsigncontent($secondsignarray);
        $stringsigntemp=$stringa."&key=db0db20f5a963d1bd90c27e644cbf812";
        return strtoupper(md5($stringsigntemp));
    }

    //基础签名
    public function getsigncontent($params){
        ksort($params);        //将参数数组按照参数名ascii码从小到大排序
        foreach ($params as $key => $item) {
            if (!empty($item)) {         //剔除参数值为空的参数
                $newarr[] = $key.'='.$item;     // 整合新的参数数组
            }
        }
        $stringa = implode("&", $newarr);         //使用 & 符号连接参数

        return $stringa;
    }
    /**
     *  作用：产生随机字符串，不长于32位
     */
    public function createnoncestr($length = 32 ){
        $chars = "abcdefghijklmnopqrstuvwxyz0123456789";
        $str ="";
        for ( $i = 0; $i < $length; $i++ )  {
            $str.= substr($chars, mt_rand(0, strlen($chars)-1), 1);
        }
        return $str;
    }

    /***
     * 微信支付回调接口
     */
    function wx_notify(request $request){
        //接收微信返回的数据数据,返回的xml格式
        $xmldata = file_get_contents('php://input');
        //将xml格式转换为数组
        $data = $this->xmldataparse($xmldata);
        //用日志记录检查数据是否接受成功，验证成功一次之后，可删除。
        $log_file_path = '/home/wwwroot/api.xmeiz.cn/';
        $file = fopen($log_file_path.'data_log.txt', 'a+');
        fwrite($file,var_export($data,true));
        //为了防止假数据，验证签名是否和返回的一样。
        //记录一下，返回回来的签名，生成签名的时候，必须剔除sign字段。
//        $data = array (
//            'appid' => 'wx751336ae9909617e',
//            'bank_type' => 'cft',
//            'cash_fee' => '1',
//            'device_info' => 'web',
//            'fee_type' => 'cny',
//            'is_subscribe' => 'n',
//            'mch_id' => '1494096322',
//            'nonce_str' => 'phmtn6kt6e18v9zc5w3y8iplftazo338',
//            'openid' => 'ot7dh1v2en2tlwv-qx3wns9pdnl8',
//            'out_trade_no' => '2018012516143937023',
//            'result_code' => 'success',
//            'return_code' => 'success',
//            'sign' => '3a3fc518f1c669f9a22caa111d5c32b7',
//            'time_end' => '20180125161500',
//            'total_fee' => '1',
//            'trade_type' => 'app',
//            'transaction_id' => '4200000090201801250608612631',
//        );

        $sign = $data['sign'];
        unset($data['sign']);
        if($sign == $this->producewechatsign($data)){
            //签名验证成功后，判断返回微信返回的
            if ($data['result_code'] == 'success') {
                //根据返回的订单号做业务逻辑

                //根据order_sn 更新所有订单的状态  order_status=1,pay_status=2,pay_fee=支付的金额,money_paid=支付的金额，pay_time订单支付时间，、
                //更新pay_log表  order_id,order_amount金额,order_type=0 订单支付,is_paid=1
                $order_info_update = array(
                    'order_status'=>1,
                    'pay_status'=>2,
//                    'pay_fee'=>($data['total_fee'])/100,
                    'money_paid'=>($data['total_fee'])/100,
                    'pay_time'=>strtotime($data['time_end'])
                );

                if(db::table('order_info')->where('order_sn',$data['out_trade_no'])->update($order_info_update)){
                    //根据order_sn 查找order_id
                    $order_info = db::table('order_info')->where('order_sn',$data['out_trade_no'])->first();
                    $order_id = $order_info->order_id;

                    $pay_log_update = array(
                        'is_paid'=>1,
                        'transid'=>$data['transaction_id'],
                        'openid'=>$data['openid']
                    );
                    if(db::table('pay_log')->where('order_id',$order_id)->update($pay_log_update)){
                        //处理完成之后，告诉微信成功结果！
                        echo '<xml>
                          <return_code><![cdata[success]]></return_code>
                          <return_msg><![cdata[ok]]></return_msg>
                          </xml>';exit();
                    }
                }
            }
            //支付失败，输出错误信息
            else{
                $file = fopen($log_file_path.'log.txt', 'a+');
                fwrite($file,"错误信息：".$data['return_msg'].date("y-m-d h:i:s"),time()."\r\n");
            }
        }
        else{
            $file = fopen($log_file_path.'log.txt', 'a+');
            fwrite($file,"错误信息：签名验证失败".date("y-m-d h:i:s"),time()."\r\n");
        }

    }
}