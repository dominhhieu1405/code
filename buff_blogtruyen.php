<?php

function input($text = '') {
	echo "$text: ";
	$input = trim(fgets(STDIN));
	return $input;
}

$comicurl = 'https://blogtruyen.vn/26958/koisuru-otome-no-tsukurikata';
$comicid = 26958;
$chapid = 690844;


// php /home/blogtruyen.php
$i = 0;
while(true){
$i++;
$curl = curl_init();

curl_setopt_array($curl, array(
  CURLOPT_URL => 'https://m.blogtruyen.vn/Chapter/UpdateView',
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_ENCODING => '',
  CURLOPT_MAXREDIRS => 10,
  CURLOPT_TIMEOUT => 0,
  CURLOPT_FOLLOWLOCATION => true,
  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
  CURLOPT_CUSTOMREQUEST => 'POST',
  CURLOPT_POSTFIELDS => "mangaId=$comicid&chapterId=$chapid",
  CURLOPT_HTTPHEADER => array(
    'accept-language: en-US,en;q=0.9,vi;q=0.8,id;q=0.7,zh-CN;q=0.6,zh;q=0.5',
    'content-type: application/x-www-form-urlencoded; charset=UTF-8',
    "referer: $comicurl",
    'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.104 Mobile Safari/537.36',
    'Cookie: RdBsw44wJZ=7B2944EFDC75A5F057EBD6A59A27CA2F'
  ),
));

$response = curl_exec($curl);

curl_close($curl);
echo "$i\n";
}