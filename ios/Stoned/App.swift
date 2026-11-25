import UIKit
import WebKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {}

final class GameSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

private final class GameErrorHandler: NSObject, WKScriptMessageHandler {
    var showError: (() -> Void)?

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.frameInfo.isMainFrame, message.frameInfo.request.url?.isFileURL == true else { return }
        showError?()
    }
}

final class GameViewController: UIViewController, WKNavigationDelegate {
    private let background = UIColor(red: 0.065, green: 0.047, blue: 0.036, alpha: 1)
    private let parchment = UIColor(red: 0.90, green: 0.83, blue: 0.69, alpha: 1)
    private let menu = UIScrollView()
    private let detail = UILabel()
    private let play = UIButton(type: .system)
    private let gameErrorHandler = GameErrorHandler()
    private var activeNavigation: WKNavigation?

    private lazy var game: WKWebView = {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.allowsInlineMediaPlayback = true
        config.userContentController.add(gameErrorHandler, name: "gameError")
        config.userContentController.addUserScript(WKUserScript(
            source: """
            window.addEventListener("error", function (event) {
                if (/WebGL context/i.test(event.message || "")) {
                    window.webkit.messageHandlers.gameError.postMessage("WebGL startup failed");
                }
            });
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        return webView
    }()

    override var prefersStatusBarHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = background
        gameErrorHandler.showError = { [weak self] in
            self?.showMenu(message: "The 3D scene couldn’t start on this device. You can try loading the game again.")
        }

        view.addSubview(game)
        NSLayoutConstraint.activate([
            game.topAnchor.constraint(equalTo: view.topAnchor),
            game.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            game.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            game.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        configureMenu()
    }

    private func configureMenu() {
        let title = UILabel()
        title.text = "STONED"
        title.textAlignment = .center
        title.font = .preferredFont(forTextStyle: .largeTitle)
        title.adjustsFontForContentSizeCategory = true
        title.textColor = parchment
        title.accessibilityTraits.insert(.header)

        detail.text = "A first-person horror game inspired by Scripture. Includes depictions of execution and themes of death and judgment."
        detail.numberOfLines = 0
        detail.textAlignment = .center
        detail.textColor = parchment
        detail.font = .preferredFont(forTextStyle: .body)
        detail.adjustsFontForContentSizeCategory = true

        var playStyle = UIButton.Configuration.filled()
        playStyle.title = "Play"
        playStyle.baseBackgroundColor = parchment
        playStyle.baseForegroundColor = background
        play.configuration = playStyle
        play.addTarget(self, action: #selector(startGame), for: .touchUpInside)

        let privacy = UIButton(type: .system)
        privacy.setTitle("Privacy Policy", for: .normal)
        privacy.tintColor = parchment
        privacy.addTarget(self, action: #selector(showPrivacy), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, detail, play, privacy])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.addSubview(stack)
        view.addSubview(menu)

        let center = stack.centerYAnchor.constraint(equalTo: menu.frameLayoutGuide.centerYAnchor)
        center.priority = .defaultHigh
        let width = stack.widthAnchor.constraint(equalToConstant: 420)
        width.priority = .defaultHigh

        NSLayoutConstraint.activate([
            menu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            menu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            menu.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            menu.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            menu.contentLayoutGuide.widthAnchor.constraint(equalTo: menu.frameLayoutGuide.widthAnchor),
            menu.contentLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: menu.frameLayoutGuide.heightAnchor),
            stack.topAnchor.constraint(greaterThanOrEqualTo: menu.contentLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: menu.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.centerXAnchor.constraint(equalTo: menu.contentLayoutGuide.centerXAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualTo: menu.frameLayoutGuide.widthAnchor, constant: -40),
            play.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            privacy.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            center, width
        ])
        let contentHeight = menu.contentLayoutGuide.heightAnchor.constraint(equalTo: menu.frameLayoutGuide.heightAnchor)
        contentHeight.priority = .defaultLow
        contentHeight.isActive = true
    }

    @objc private func startGame() {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else {
            showMenu(message: "The game file is missing from this build.")
            return
        }
        game.isHidden = false
        menu.isHidden = true
        activeNavigation = game.loadFileURL(url, allowingReadAccessTo: url)
    }

    private func showMenu(message: String) {
        activeNavigation = nil
        game.stopLoading()
        game.isHidden = true
        menu.isHidden = false
        detail.text = message
        var style = play.configuration
        style?.title = "Try Again"
        play.configuration = style
        UIAccessibility.post(notification: .screenChanged, argument: detail)
    }

    @objc private func showPrivacy() {
        guard let url = Bundle.main.url(forResource: "Privacy", withExtension: "txt"),
              let policy = try? String(contentsOf: url, encoding: .utf8) else { return }
        let alert = UIAlertController(title: "Privacy Policy", message: policy, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let allowed = navigationAction.request.url == Bundle.main.url(forResource: "index", withExtension: "html")
        decisionHandler(allowed ? .allow : .cancel)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        showLoadingError(for: navigation)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoadingError(for: navigation)
    }

    private func showLoadingError(for navigation: WKNavigation?) {
        guard let activeNavigation, let navigation, activeNavigation === navigation else { return }
        showMenu(message: "The game couldn’t load. You can try again.")
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard !game.isHidden else { return }
        showMenu(message: "The game was interrupted. Start again from the title screen.")
    }
}
