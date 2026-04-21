import Flutter
import UIKit
import WebKit

class YoutubePlayerFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return YoutubePlayerPlatformView(frame: frame, viewId: viewId, messenger: messenger, args: args as? [String: Any] ?? [:])
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class YoutubePlayerPlatformView: NSObject, FlutterPlatformView, WKNavigationDelegate, WKScriptMessageHandler {
    private let webView: WKWebView
    private let channel: FlutterMethodChannel
    private let videoId: String
    private let autoPlay: Bool

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: [String: Any]) {
        videoId = args["videoId"] as? String ?? ""
        autoPlay = args["autoPlay"] as? Bool ?? false

        channel = FlutterMethodChannel(name: "youtube-player-\(viewId)", binaryMessenger: messenger)

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let userContentController = WKUserContentController()
        config.userContentController = userContentController

        webView = WKWebView(frame: frame, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        super.init()

        userContentController.add(self, name: "playerEvent")
        webView.navigationDelegate = self
        channel.setMethodCallHandler(handleMethodCall)

        loadPlayer()
    }

    func view() -> UIView {
        return webView
    }

    private func loadPlayer() {
        let autoPlayNum = autoPlay ? 1 : 0
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
        <style>
        *{margin:0;padding:0;overflow:hidden;background:#000}
        #player{position:absolute;top:0;left:0;width:100%;height:100%}
        </style>
        </head>
        <body>
        <div id="player"></div>
        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
        var player;
        function onYouTubeIframeAPIReady(){
            player=new YT.Player('player',{
                videoId:'\(videoId)',
                playerVars:{controls:0,rel:0,showinfo:0,modestbranding:1,iv_load_policy:3,playsinline:1,autoplay:\(autoPlayNum),loop:1,playlist:'\(videoId)'},
                events:{
                    onReady:function(e){
                        window.webkit.messageHandlers.playerEvent.postMessage('ready');
                    },
                    onStateChange:function(e){
                        window.webkit.messageHandlers.playerEvent.postMessage('state:'+e.data);
                        if(e.data===0){player.seekTo(0);player.playVideo();}
                    },
                    onError:function(e){
                        window.webkit.messageHandlers.playerEvent.postMessage('error:'+e.data);
                    }
                }
            });
        }
        function playVideo(){player&&player.playVideo();}
        function pauseVideo(){player&&player.pauseVideo();}
        function loadNewVideo(id){player&&player.loadVideoById(id);}
        function seekTo(s){player&&player.seekTo(s,true);}
        </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else { return }
        if body == "ready" {
            channel.invokeMethod("onReady", arguments: nil)
        } else if body.hasPrefix("state:") {
            let state = String(body.dropFirst(6))
            channel.invokeMethod("onStateChange", arguments: state)
        } else if body.hasPrefix("error:") {
            let error = String(body.dropFirst(6))
            channel.invokeMethod("onError", arguments: error)
        }
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "play":
            webView.evaluateJavaScript("playVideo()", completionHandler: nil)
            result(nil)
        case "pause":
            webView.evaluateJavaScript("pauseVideo()", completionHandler: nil)
            result(nil)
        case "loadVideo":
            if let args = call.arguments as? [String: Any], let id = args["videoId"] as? String {
                webView.evaluateJavaScript("loadNewVideo('\(id)')", completionHandler: nil)
            }
            result(nil)
        case "seekTo":
            if let args = call.arguments as? [String: Any], let seconds = args["seconds"] as? Double {
                webView.evaluateJavaScript("seekTo(\(seconds))", completionHandler: nil)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
