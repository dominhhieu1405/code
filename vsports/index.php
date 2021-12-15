<?php
$post = "https://vsports.com.vn/posts/10500";
$postID = '10500';
$pass = '@HieuPro1s';
include('mailtm.php');
$mail = new Mailtm();

function console($str = ""){
    echo "  ==> $str\n";
}
start:
//Random User Agent
$uas = explode("\n",file_get_contents('ua.txt'));
$ua = $uas[array_rand($uas)];

$first = explode("\n", file_get_contents('first.txt'));
$last = explode("\n", file_get_contents('last.txt'));
gen_first:
$gf = trim($first[array_rand($first)]);
gen_last:
$gl = trim($last[array_rand($last)]);

$ua = 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1';

$name = "$gl $gf";
console("Tên: $name");
$domains = ($mail->getDomains());
$email = Bodau($name) . rand(0,999) .'@'.$domains['hydra:member'][0]['domain'];
console("Email: $email");

console();
console("Đang tạo email...");
$regMail = $mail->register($email, $pass);
//$email = 'huyetkimsatinhbanh327@alilot.com';
$logMail = $mail->login($email, $pass);

console("Đang truy cập web...");
$headers = [
    "accept: application/json, text/plain, */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNTk5MTUyMjgzLCJleHAiOjE2MzA2ODgyODMsImlzcyI6InZzcG9ydHMifQ.v9zKtX6avlYfsFpc67l16ay0JCYOH1dV-F_Nt0dqyNg",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
//Tạo acc
$c = curl_init("https://vsports.com.vn/");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$home = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

$headers = [
    "accept: application/json, text/plain, */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNTk5MTUyMjgzLCJleHAiOjE2MzA2ODgyODMsImlzcyI6InZzcG9ydHMifQ.v9zKtX6avlYfsFpc67l16ay0JCYOH1dV-F_Nt0dqyNg",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
console("Đang truy cập api thông tin...");
$c = curl_init("https://apis.vsports.com.vn/v1/notifications/me?page=1");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$me = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

console();
$headers = [
    "accept: application/json, text/plain, */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNTk5MTUyMjgzLCJleHAiOjE2MzA2ODgyODMsImlzcyI6InZzcG9ydHMifQ.v9zKtX6avlYfsFpc67l16ay0JCYOH1dV-F_Nt0dqyNg",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
console("Đang truy cập api thông tin 2...");
$c = curl_init("https://apis.vsports.com.vn/v1/roles");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$roles = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

$headers = [
    "accept: */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
console("Đang truy cập api thông tin 3...");
$c = curl_init("https://analytic.vsports.com.vn/v1/tracking?referrer=&page_url=https://vsports.com.vn/");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$tracking = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

//die($tracking);
//Lấy mã xác minh
console();
send_code:
$data = [
    'email' => $email
];
$headers = [
    "accept: */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNTk5MTUyMjgzLCJleHAiOjE2MzA2ODgyODMsImlzcyI6InZzcG9ydHMifQ.v9zKtX6avlYfsFpc67l16ay0JCYOH1dV-F_Nt0dqyNg",
    "cache-control: no-cache",
    "content-length: " . strlen(json_encode($data)),
    "content-type: application/json;charset=UTF-8",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua",
    'Content-Type: application/x-www-form-urlencoded'
];
console("Đang gửi mã xác minh...");
$c = curl_init('https://apis.vsports.com.vn/v1/auth/send-verify-code');
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, "https://vsports.com.vn/");
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, "cookie.txt");
curl_setopt($c, CURLOPT_COOKIEFILE, "cookie.txt");
// Thiết lập sử dụng POST
//curl_setopt($c, CURLOPT_POST, count($data));

// Thiết lập các dữ liệu gửi đi
curl_setopt($c, CURLOPT_POSTFIELDS, json_encode($data));

$response = curl_exec($c);
$httpcode = curl_getinfo($c);
var_dump(curl_error($c));
$sendcode = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

var_dump($response);

//Lấy mã xác thực
console("Bắt đầu lấy mã xác thực...");
$check_count = 0;
getmail:
if ($check_count == 1) {
    console("Lấy mã xác thực thất bại, đang thử lại...");
} else if ($check_count > 0){
    if ($check_count == 13){
        console("[$check_count] Thử lại quá nhiều lần thất bại, không có email xác minh...");
        console("Đang gửi lại mã xác minh...");
        goto send_code;
    }
    console("[$check_count] Thử lại lần thứ $check_count thất bại, đang thử lại...");
    sleep(7);
}
$mes = $mail->getMessages();
if (count($mes['hydra:member']) == 0) {$check_count++; goto getmail;}
//var_dump($mes);
$msg = $mes['hydra:member'][0];
if ($msg['from']['address'] != 'vsports.noreply@gmail.com') {$check_count++; goto getmail;}
preg_match_all('/Mã xác thực tài khoản của bạn là ([0-9]+)./', $msg['intro'], $code);
$code = $code[1][0];
console("MÃ XÁC MINH: $code");
//Kiểm tra mã xác thực
console("Kiểm tra mã xác minh...");
$data = [
    'code' =>$code,
    'uid' => $email
];
$headers = [
    "accept: */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNTk5MTUyMjgzLCJleHAiOjE2MzA2ODgyODMsImlzcyI6InZzcG9ydHMifQ.v9zKtX6avlYfsFpc67l16ay0JCYOH1dV-F_Nt0dqyNg",
    "cache-control: no-cache",
    "content-length: " . strlen(json_encode($data)),
    "content-type: application/json;charset=UTF-8",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
$c = curl_init('https://apis.vsports.com.vn/v1/auth/verify-code');
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, "https://vsports.com.vn/");
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
// Thiết lập sử dụng POST
//curl_setopt($c, CURLOPT_POST, count($data));

// Thiết lập các dữ liệu gửi đi
curl_setopt($c, CURLOPT_POSTFIELDS, json_encode($data));

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, "cookie.txt");
curl_setopt($c, CURLOPT_COOKIEFILE, "cookie.txt");
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$checkcode = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

//Thực hiện tạo tài khoản
console();
console("Đang tạo tài khoản...");
$data = [
    'email' => $email,
    'name' => $name,
    'password' => $email
];
$headers = [
    "accept: */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiaWF0IjoxNTk5MTUyMjgzLCJleHAiOjE2MzA2ODgyODMsImlzcyI6InZzcG9ydHMifQ.v9zKtX6avlYfsFpc67l16ay0JCYOH1dV-F_Nt0dqyNg",
    "cache-control: no-cache",
    "content-length: " . strlen(json_encode($data)),
    "content-type: application/json;charset=UTF-8",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
$c = curl_init('https://apis.vsports.com.vn/v1/auth/signup/email');
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, "https://vsports.com.vn/");
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
// Thiết lập sử dụng POST
//curl_setopt($c, CURLOPT_POST, count($data));

// Thiết lập các dữ liệu gửi đi
curl_setopt($c, CURLOPT_POSTFIELDS, json_encode($data));

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, "cookie.txt");
curl_setopt($c, CURLOPT_COOKIEFILE, "cookie.txt");
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$regCheck = json_decode(substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE)), true);
curl_close($c);
$token = $regCheck['data']['token'];

//Lưu acc
$fp = @fopen('acc.txt', 'a+');
$acc = "\n$email|$pass|$token";
fwrite($fp, $acc);
fclose($fp);

//Truy cập bài viết
console("Đang truy cập bài viết...");
$headers = [
    "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer e$token",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "upgrade-insecure-requests: 1",
    "user-agent: $ua"
];
$c = curl_init($post);
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$home = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

//Check
console("Đang ping đến server...");
$headers = [
    "accept: application/json, text/plain, */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer $token",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
$c = curl_init("https://analytic.vsports.com.vn/v1/tracking?referrer=&page_url=$post");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$pingPost1 = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);
//Check
console("Đang ping đến server 2...");
$headers = [
    "accept: application/json, text/plain, */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer $token",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
$c = curl_init("https://apis.vsports.com.vn/v1/posts/likes/$postID/post?page=1&per_page=10");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$pingPost2 = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);
//Check
console("Đang ping đến server 3...");
$headers = [
    "accept: */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "cache-control: no-cache",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
$c = curl_init("https://analytic.vsports.com.vn/v1/tracking?referrer=&page_url=$post");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, 'https://vsports.com.vn');
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, 'cookie.txt');
curl_setopt($c, CURLOPT_COOKIEFILE, 'cookie.txt');
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$pingPost3 = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
curl_close($c);

//Thực hiện like bài viết
console();
console("Đang nhấn nút like...");
$headers = [
    "accept: application/json, text/plain, */*",
    "accept-encoding: gzip, deflate, br",
    "accept-language: en-US,en;q=0.9",
    "authorization: Bearer $token",
    "cache-control: no-cache",
    "content-length: 0",
    "origin: https://vsports.com.vn",
    "pragma: no-cache",
    "referer: https://vsports.com.vn/",
    "sec-fetch-dest: empty",
    "sec-fetch-mode: cors",
    "sec-fetch-site: same-site",
    "user-agent: $ua"
];
$c = curl_init("https://apis.vsports.com.vn/v1/posts/likes/$postID/post");
curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($c, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);
curl_setopt($c, CURLOPT_USERAGENT, "$ua");
curl_setopt($c, CURLOPT_REFERER, "https://vsports.com.vn/");
curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate, br');
// Thiết lập sử dụng POST
//curl_setopt($c, CURLOPT_POST, count($data));

// Thiết lập các dữ liệu gửi đi
//curl_setopt($c, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($c, CURLOPT_CUSTOMREQUEST, 'PUT');
curl_setopt($c, CURLOPT_HEADER, true);
curl_setopt($c, CURLOPT_HTTPHEADER, $headers);
curl_setopt($c, CURLOPT_COOKIEJAR, "cookie.txt");
curl_setopt($c, CURLOPT_COOKIEFILE, "cookie.txt");
$response = curl_exec($c);
$httpcode = curl_getinfo($c);
$checkLike = json_decode(substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE)), true);
curl_close($c);
$totalLike = $checkLike['data']['total_likes'];

console("Đã bình chọn, hiện đang có $totalLike lượt bình chọn");




unlink('cookie.txt');
console();
console("Tạm ngưng 5 phút...");
console();
console();
sleep(60);
goto start;