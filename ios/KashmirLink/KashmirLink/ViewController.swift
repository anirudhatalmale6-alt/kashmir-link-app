import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!
    private var offlineView: UIView!
    private var activityIndicator: UIActivityIndicatorView!

    private let websiteURL = URL(string: "https://kashmir.link/")!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        setupWebView()
        setupProgressView()
        setupRefreshControl()
        setupOfflineView()
        setupNotificationObserver()

        loadWebsite()
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsPictureInPictureMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true

        // Custom user agent
        webView.customUserAgent = (webView.value(forKey: "userAgent") as? String ?? "") + " KashmirLinkApp/1.0"

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Observe loading progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(red: 0.86, green: 0.21, blue: 0.27, alpha: 1.0) // #DC3545
        progressView.isHidden = true

        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3)
        ])
    }

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }

    private func setupOfflineView() {
        offlineView = UIView()
        offlineView.translatesAutoresizingMaskIntoConstraints = false
        offlineView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        offlineView.isHidden = true

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16

        let iconLabel = UILabel()
        iconLabel.text = "📡"
        iconLabel.font = .systemFont(ofSize: 60)

        let titleLabel = UILabel()
        titleLabel.text = "No Internet Connection"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Please check your connection and try again"
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.backgroundColor = UIColor(red: 0.86, green: 0.21, blue: 0.27, alpha: 1.0)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        retryButton.addTarget(self, action: #selector(retryConnection), for: .touchUpInside)

        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(retryButton)

        offlineView.addSubview(stackView)

        view.addSubview(offlineView)

        NSLayoutConstraint.activate([
            offlineView.topAnchor.constraint(equalTo: view.topAnchor),
            offlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: offlineView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: offlineView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: offlineView.leadingAnchor, constant: 32)
        ])
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenURL(_:)), name: NSNotification.Name("OpenURL"), object: nil)
    }

    @objc private func handleOpenURL(_ notification: Notification) {
        if let url = notification.object as? URL {
            webView.load(URLRequest(url: url))
        }
    }

    private func loadWebsite() {
        if isConnectedToNetwork() {
            offlineView.isHidden = true
            webView.isHidden = false
            webView.load(URLRequest(url: websiteURL))
        } else {
            showOfflineView()
        }
    }

    @objc private func refreshWebView() {
        if isConnectedToNetwork() {
            offlineView.isHidden = true
            webView.isHidden = false
            webView.reload()
        } else {
            refreshControl.endRefreshing()
            showOfflineView()
        }
    }

    @objc private func retryConnection() {
        loadWebsite()
    }

    private func showOfflineView() {
        webView.isHidden = true
        offlineView.isHidden = false
    }

    private func isConnectedToNetwork() -> Bool {
        // Simple connectivity check
        guard let url = URL(string: "https://www.apple.com") else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.httpMethod = "HEAD"

        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false

        URLSession.shared.dataTask(with: request) { _, response, _ in
            isConnected = (response as? HTTPURLResponse)?.statusCode == 200
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return isConnected
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.progress = 0
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        showOfflineView()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        showOfflineView()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            // Open external links in Safari
            if !url.host?.contains("kashmir.link") ?? true && navigationAction.navigationType == .linkActivated {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }

    // MARK: - Progress Observer

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        NotificationCenter.default.removeObserver(self)
    }
}
