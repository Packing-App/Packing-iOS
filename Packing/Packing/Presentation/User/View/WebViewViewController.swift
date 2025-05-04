//
//  WebViewViewController.swift
//  Packing
//
//  Created by 이융의 on 5/4/25.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    // MARK: - Properties
    private let urlString: String
    private let pageTitle: String
    
    // MARK: - Initialization
    init(urlString: String, title: String) {
        self.urlString = urlString
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebContent()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = pageTitle
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 네비게이션 바 버튼 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshWebView)
        )
    }
    
    // MARK: - Actions
    @objc private func refreshWebView() {
        loadWebContent()
    }
    
    // MARK: - Methods
    private func loadWebContent() {
        loadingIndicator.startAnimating()
        
        guard let url = URL(string: urlString) else {
            showErrorAlert(message: "유효하지 않은 URL입니다.")
            loadingIndicator.stopAnimating()
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: "페이지를 로드하는 데 문제가 발생했습니다: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showErrorAlert(message: "페이지를 로드하는 데 문제가 발생했습니다: \(error.localizedDescription)")
    }
}
