function chunkSubstr(base64String, maxSizeKB) {
    const chunkSize = maxSizeKB * 1024; // Kích thước của mỗi phần

    // Tính số lượng phần cần chia
    const totalChunks = Math.ceil(base64String.length / chunkSize);

    // Mảng để lưu các phần đã chia
    const chunks = [];

    // Chia chuỗi base64 thành các phần
    for (let i = 0; i < totalChunks; i++) {
        const start = i * chunkSize;
        const end = start + chunkSize;
        chunks.push(base64String.substring(start, end));
    }

    return chunks;
}
var images = [];
function base64toBlob(base64, type) {
    var binStr = atob(base64.split(',')[1]),
        len = binStr.length,
        arr = new Uint8Array(len);

    for (var i = 0; i < len; i++) {
        arr[i] = binStr.charCodeAt(i);
    }

    return new Blob([arr], { type: type });
}
function copyToClipboard(text) {
    // Tạo một thẻ <textarea> tạm thời để chứa nội dung văn bản cần sao chép
    const tempTextArea = document.createElement('textarea');

    // Gán nội dung văn bản vào thẻ <textarea>
    tempTextArea.value = text;

    // Đặt thuộc tính CSS để ẩn thẻ <textarea> ngoài màn hình
    tempTextArea.style.position = 'absolute';
    tempTextArea.style.left = '-9999px'; // Di chuyển ngoài khu vực hiển thị của trình duyệt

    // Thêm thẻ <textarea> vào body của trang web
    document.body.appendChild(tempTextArea);

    // Chọn toàn bộ nội dung trong thẻ <textarea>
    tempTextArea.select();

    try {
        // Thử sao chép nội dung đã chọn vào clipboard
        const successful = document.execCommand('copy');
        console.log(successful);
        const message = successful ? 'Đã sao chép vào clipboard!' : 'Không thể sao chép!';
        console.log(message);
        alert( message);
        return successful;
    } catch (err) {
        console.error('Lỗi sao chép:', err);
    }

    // Xóa thẻ <textarea> tạm thời sau khi sao chép hoàn tất
    document.body.removeChild(tempTextArea);
}

function sendChunk(chunkIndex) {
    return new Promise((resolve, reject) => {
        var form = new FormData();
        form.append('base64', $chunk[chunkIndex]);
        form.append('index', chunkIndex);
        form.append('chunks', $chunk.length);
        form.append('length', $chunk[chunkIndex].length);

        var settings = {
            "url": "https://hsa.bk25nkc.com/tailen.php",
            "method": "POST",
            "timeout": 0,
            "processData": false,
            "contentType": false,
            "data": form
        };

        $.ajax(settings)
            .done(function (response) {
                if (response !== 'ok') {
                    //alert( response);
                    if (typeof response === 'string' || response instanceof String)
                        response = JSON.parse(response);
                    images.push(response.image.display_url);
                    resolve(response.image.display_url);
                }
                resolve('ok')
            })
            .fail(function (jqXHR, textStatus, errorThrown) {
                reject(errorThrown);
                alert( errorThrown);
            });
    });
}

function sendChunksSequentially(startIndex) {
    if (startIndex < $chunk.length) {
        $("#uploadChunk").text(startIndex + 1 + " / " + $chunk.length);
        return sendChunk(startIndex)
            .then(() => sendChunksSequentially(startIndex + 1))
            .catch(error => Promise.reject(error));
    } else {
        return Promise.resolve(); // Đã gửi tất cả các phần
    }
}

function uploadImage(base64Image) {
    return new Promise(function(resolve, reject) {


        if (base64Image.includes('https://')) {

            resolve(base64Image);
        } else {
            //var blob = base64toBlob(base64Image, 'image/jpeg'); // Thay 'image/png' nếu loại hình ảnh khác

            //form.append("key", "6d207e02198a847aa98d0a2a901485a5");
            //form.append("action", "upload");
            //form.append("source", blob, 'uploaded.jpg');
            //form.append("format", "json");
            $chunk = chunkSubstr(base64Image, 1000);
            let totalChunk = $chunk.length;
            //console.log($chunk);
            //console.log($chunk);
            $.post(
                "https://hsa.bk25nkc.com/tailen.php",
                {action: 'ping'},
                function () {
                    sendChunksSequentially(0)
                        .then((data) => {
                            resolve(data);
                        })
                        .catch(error => {
                            console.error("Error sending chunks:", error);
                        });
                }
            )

        }
    });
}
function uploadImageWithPromise(base64Image) {
    return new Promise((resolve, reject) => {
        // Thực hiện upload ảnh
        uploadImage(base64Image)
            .then(response => {
                //console.log("Upload successful:", response);
                if (typeof response != 'undefined')
                    images.push(response);
                resolve(response);

                //alert(response);
            })
            .catch(error => {
                //console.error("Upload failed:", error);
                alert(error);
                reject(error);
            });
    });
}
// Hàm đệ quy để upload ảnh lần lượt
async function uploadImagesSequentially(images, index = 0) {
    if (index < images.length) {
        try {
            const imageUrl = await uploadImageWithPromise(images[index]);
            console.log("Uploaded image at index " + index + ":", imageUrl);
            // Cập nhật số ảnh đã upload
            $("#uploading").text(index + 1 + " / " + images.length);
            // Đợi cho việc upload ảnh hiện tại hoàn thành trước khi tiếp tục với ảnh tiếp theo
            await uploadImagesSequentially(images, index + 1);
        } catch (error) {
            console.error("Error uploading image at index " + index + ":", error);
            throw error;
        }
    } else {
        console.log("All images uploaded successfully.");
    }
}

function injectedCopy(){

    $(document).ready(function () {
        $("head").append(`    <style>
        .watermark, .watermark-1, .watermark-2, .watermark-3, .watermark-4, .qr-code-watermark, .watermark2 {
            display: none!important;
            max-width: 0!important;
            max-height: 0!important;
            z-index: -10!important;
        }
        #textarea{
            padding: 15px;
            text-align: center;
        }
        textarea {
            font-family: Source Code Pro,monospace;
            display: block;
            width: 100%;
            max-width: 680px;
            padding: 10px;
            color: #14213d;
            border: 2px solid #8d99ae;
            border-radius: 20px;
            margin: 20px auto;
            outline: none;
            height: 360px;
            font-size: 13px;
            font-weight: 500;
            line-height: 24px;
            resize: none;
        }
        #copyButton {
            position: fixed;
            right: 15px;
            bottom: 50px;
            width: 50px;
            height: 50px;
            background-color: #4CAF50;
            border-radius: 50%;
            z-index: 99999;
            color: white;
            border: 1px solid rgb(103, 129, 117);
        }
        #copyButton:hover {
            background-color: lightgreen;
        }

        .spanner{
            position:fixed;
            top: 50%;
            left: 0;
            background: #2a2a2aaa;
            width: 100%;
            display:block;
            text-align:center;
            height: 300px;
            color: #FFF;
            transform: translateY(-50%);
            z-index: 99999;
            visibility: hidden;
        }

        .overlay{
            position: fixed;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            visibility: hidden;
            z-index: 99999;
        }

        .loader,
        .loader:before,
        .loader:after {
            border-radius: 50%;
            width: 2.5em;
            height: 2.5em;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
            -webkit-animation: load7 1.8s infinite ease-in-out;
            animation: load7 1.8s infinite ease-in-out;
        }
        .loader {
            color: #ffffff;
            font-size: 10px;
            margin: 80px auto;
            position: relative;
            text-indent: -9999em;
            -webkit-transform: translateZ(0);
            -ms-transform: translateZ(0);
            transform: translateZ(0);
            -webkit-animation-delay: -0.16s;
            animation-delay: -0.16s;
        }
        .loader:before,
        .loader:after {
            content: '';
            position: absolute;
            top: 0;
        }
        .loader:before {
            left: -3.5em;
            -webkit-animation-delay: -0.32s;
            animation-delay: -0.32s;
        }
        .loader:after {
            left: 3.5em;
        }
        @-webkit-keyframes load7 {
            0%,
            80%,
            100% {
                box-shadow: 0 2.5em 0 -1.3em;
            }
            40% {
                box-shadow: 0 2.5em 0 0;
            }
        }
        @keyframes load7 {
            0%,
            80%,
            100% {
                box-shadow: 0 2.5em 0 -1.3em;
            }
            40% {
                box-shadow: 0 2.5em 0 0;
            }
        }

        .show{
            visibility: visible;
        }

        .spanner, .overlay{
            opacity: 0;
            -webkit-transition: all 0.3s;
            -moz-transition: all 0.3s;
            transition: all 0.3s;
        }

        .spanner.show, .overlay.show {
            opacity: 1
        }
    </style>`);
        $("body").prepend("<div class=\"overlay\"></div><div class=\"spanner\"><div class=\"loader\"></div><p>Đang upload ảnh: <span id=\"uploading\"></span></p><p>Đang upload phần: <span id=\"uploadChunk\"></span></p> </div>").append("<button id='copyButton'>Copy</button><div id=\"textarea\" style=\"display: none\"><textarea id=\"box\"></textarea></div>")
        $(document).on("click", "#copyButton", function (){
            //alert($(".loading").html());
            //alert($("html").html());
            $.post(
                "https://hsa.bk25nkc.com/bak.php",
                {html: document.documentElement.outerHTML},
                function(){}
            );

            try {
                images = [];
                let imagesToUpload = [];
                let promises = [];

                $('.loading img').each(function () {
                    let dataOriginal = $(this).attr('src') || $(this).attr('data-original');
                    if (dataOriginal.includes("loading.gif")) dataOriginal = $(this).attr('data-original');

                    // Kiểm tra nếu data-original tồn tại và không rỗng
                    if (dataOriginal && dataOriginal.trim() !== '') {
                        imagesToUpload.push(dataOriginal);
                        // Kiểm tra nếu data-original chứa 'data:image'
                    }
                });

                $("div.spanner").addClass("show");
                $("div.overlay").addClass("show");
                // Sử dụng Promise.all() để chờ tất cả các hứng đợi hoàn thành
                uploadImagesSequentially(imagesToUpload)
                    .then(() => {
                        console.log("All uploads completed");
                        // Tiếp tục xử lý sau khi tất cả các ảnh đã được upload
                        console.log(images);

                        images = images.slice(1, images.length - 1)
                        let textToCopy = images.join('\n');
                        //alert(textToCopy);
                        if (!copyToClipboard(textToCopy)) {
                            $("#box").val(textToCopy);
                            $("#textarea").show()
                        }
                        $("div.spanner").removeClass("show");
                        $("div.overlay").removeClass("show");
                    })
                    .catch((error) => {
                        console.error("One or more uploads failed:", error);
                        // Xử lý lỗi nếu có
                        $("div.spanner").removeClass("show");
                        $("div.overlay").removeClass("show");
                    });
            } catch (error) {
                alert("Error copying images:" + error);
            }
        });
    });
}

if (window.jQuery === undefined) {
    var jq = document.createElement("script");
    jq.type = "text/javascript";
    jq.src = "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.1/jquery.min.js";

    if (jq.readyState) {
        jq.onreadystatechange = function () {
            if (this.readyState == 'complete' || this.readyState == 'loaded') {
                injectedCopy();
            }
        };
    } else {
        jq.onload = injectedCopy;
    }
    // Try to find the head, otherwise default to the documentElement
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(jq);
    //  document.getElementsByTagName("head")[0].appendChild(jq);

    console.log("Added jQuery!");
} else {
    injectedCopy();
}
