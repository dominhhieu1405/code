<?php
class Mailtm
{
    /**
     * @var string
     */
    private $baseUrl;
    /**
     * @var string
     */
    private $id;
    /**
     * @var string
     */
    private $address;
    /**
     * @var string
     */
    private $token;

    public function __construct()
    {
        $this->baseUrl = "https://api.mail.tm";
        $this->token = "";
        $this->id = "";
        $this->address = "";
    }

    public function send($path, $method = "GET", $body = '', $accept = 'application/json')
    {
        $url = $this->baseUrl . $path;
        $headers = [
            'accept' => $accept,
            'authorization: Bearer ' . $this->token
        ];
        $contentType = 'json';
        if (in_array($method, ["POST", "PATCH"])) {
            $contentType = $method === "PATCH" ? "merge-patch+json" : "json";
        }
        $headers[] = "Content-Type: application/$contentType";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        switch ($method) {
            case "GET":
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
                break;
            case "POST":
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
                break;
            case "PATCH":
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PATCH");
                break;
            case "DELETE":
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
                break;
        }
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        $result = json_decode(curl_exec($ch), true);
        curl_close($ch);
        return $result;
    }
    public function register($address, $password)
    {
        return $this->send("/accounts", "POST", ['address' => $address, 'password' => $password]);
    }

    /**
     * @param $address
     * @param $password
     * @return ResponseInterface
     */
    public function login($address, $password)
    {
        $res = $this->send("/token", "POST", ['address' => $address, 'password' => $password]);

        if ($res) {
            $this->token = $res['token'];
            $this->id = $res['id'];
        }

        return $res;
    }

    public function me()
    {
        return $this->send("/me");
    }

    public function getAccount($accountId)
    {
        return $this->send("/accounts/$accountId");
    }

    public function deleteAccount($accountId)
    {
        return $this->send("/accounts/$accountId", "DELETE");
    }

    public function deleteMe()
    {
        return $this->deleteAccount($this->id);
    }

    /**
     * Retrieves the collection of Domain resources.
     */
    public function getDomains()
    {
        return $this->send("/domains?page=1");
    }

    /**
     * Retrieves a Domain resource.
     * @param $domainId
     * @return ResponseInterface
     */
    public function getDomain($domainId)
    {
        return $this->send("/domains/$domainId");
    }

    /**
     * Retrieves the collection of Message resources.
     * @param int $page
     * @return ResponseInterface
     */
    public function getMessages($page = 1)
    {
        return $this->send("/messages?page=$page");
    }

    /**
     * Retrieves a Message resource.
     * @param $messageId Resource identifier
     * @return ResponseInterface
     */
    public function getMessage($messageId)
    {
        return $this->send("/messages/$messageId");
    }

    /**
     * Removes the Message resource.
     * @return ResponseInterface
     */
    public function deleteMessage($messageId)
    {
        return $this->send("/messages/$messageId", "DELETE");
    }

    /**
     * Sets a message as read or unread.
     * @param string $messageId Resource identifier
     * @param bool $seen Default true
     */
    public function setMessageSeen($messageId, $seen = true)
    {
        return $this->send("/messages/$messageId", "PATCH", $seen);
    }


    public function getSource($sourceId)
    {
        return $this->send("/sources/$sourceId");
    }
}
function Bodau($strTitle) {
    $strTitle = trim($strTitle);
    $strTitle = preg_replace("/(!|@|\$|%|\^|\*|\(|\)|\+|\=|\<|\>|\?|\/|,|\.|\:|\'| |\"|\&|\#|\[|\]|~)/", '-', $strTitle);
    $strTitle = preg_replace("/(ò|ó|ọ|ỏ|õ|ơ|ờ|ớ|ợ|ở|ỡ|ô|ồ|ố|ộ|ổ|ỗ)/", 'o', $strTitle);
    $strTitle = preg_replace("/(Ò|Ó|Ọ|Ỏ|Õ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ|Ô|Ố|Ổ|Ộ|Ồ|Ỗ)/", 'o', $strTitle);
    $strTitle = preg_replace("/(à|á|ạ|ả|ã|ă|ằ|ắ|ặ|ẳ|ẵ|â|ầ|ấ|ậ|ẩ|ẫ)/", 'a', $strTitle);
    $strTitle = preg_replace("/(À|Á|Ạ|Ả|Ã|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ|Â|Ấ|Ầ|Ậ|Ẩ|Ẫ)/", 'a', $strTitle);
    $strTitle = preg_replace("/(ề|ế|ệ|ể|ê|ễ|é|è|ẻ|ẽ|ẹ)/", 'e', $strTitle);
    $strTitle = preg_replace("/(Ể|Ế|Ệ|Ể|Ê|Ề|Ễ|É|È|Ẻ|Ẽ|Ẹ)/", 'e', $strTitle);
    $strTitle = preg_replace("/(ừ|ứ|ự|ử|ư|ữ|ù|ú|ụ|ủ|ũ)/", 'u', $strTitle);
    $strTitle = preg_replace("/(Ừ|Ứ|Ự|Ử|Ư|Ữ|Ù|Ú|Ụ|Ủ|Ũ)/", 'u', $strTitle);
    $strTitle = preg_replace("/(ì|í|ị|ỉ|ĩ)/", 'i', $strTitle);
    $strTitle = preg_replace("/(Ì|Í|Ị|Ỉ|Ĩ)/", 'i', $strTitle);
    $strTitle = preg_replace("/(ỳ|ý|ỵ|ỷ|ỹ)/", 'y', $strTitle);
    $strTitle = preg_replace("/(Ỳ|Ý|Ỵ|Ỷ|Ỹ)/", 'y', $strTitle);
    $strTitle = preg_replace('/(đ|Đ)/', 'd', $strTitle);
    $strTitle = str_replace(' ', '', $strTitle);
    $strTitle = strtolower($strTitle);
    $strTitle = preg_replace("/(^\-+|\-+$)/", '', $strTitle);
    $strTitle = html_entity_decode(trim($strTitle), ENT_QUOTES, 'UTF-8');
    $strTitle = str_replace(" ", "", $strTitle);
    $strTitle = str_replace("@", "-", $strTitle);
    $strTitle = str_replace("/", "-", $strTitle);
    $strTitle = str_replace("{", "", $strTitle);
    $strTitle = str_replace("}", "", $strTitle);
    $strTitle = str_replace("\\", "-", $strTitle);
    $strTitle = str_replace(":", "", $strTitle);
    $strTitle = str_replace("\"", "", $strTitle);
    $strTitle = str_replace("'", "", $strTitle);
    $strTitle = str_replace("<", "", $strTitle);
    $strTitle = str_replace(">", "", $strTitle);
    $strTitle = str_replace(",", "", $strTitle);
    $strTitle = str_replace("?", "", $strTitle);
    $strTitle = str_replace(";", "", $strTitle);
    $strTitle = str_replace(".", "", $strTitle);
    $strTitle = str_replace("[", "", $strTitle);
    $strTitle = str_replace("]", "", $strTitle);
    $strTitle = str_replace("(", "", $strTitle);
    $strTitle = str_replace(")", "", $strTitle);
    $strTitle = str_replace("*", "", $strTitle);
    $strTitle = str_replace("!", "", $strTitle);
    $strTitle = str_replace("$", "-", $strTitle);
    $strTitle = str_replace("&", "-and-", $strTitle);
    $strTitle = str_replace("%", "", $strTitle);
    $strTitle = str_replace("#", "", $strTitle);
    $strTitle = str_replace("^", "", $strTitle);
    $strTitle = str_replace("=", "", $strTitle);
    $strTitle = str_replace("+", "", $strTitle);
    $strTitle = str_replace("~", "", $strTitle);
    $strTitle = str_replace("`", "", $strTitle);
    $strTitle = str_replace("--", "-", $strTitle);
    $strTitle = str_replace("--", "-", $strTitle);
    $strTitle = str_replace('-', '', $strTitle);
    return $strTitle;
}