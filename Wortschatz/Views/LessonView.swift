import SwiftUI
import WebKit

struct LessonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.appTheme) private var theme
    @Environment(AppStore.self) private var store
    let entry: WordEntry
    @State private var html: String?
    @State private var error: String?
    @State private var readerLoading = true
    @State private var retry = 0
    var body: some View {
        Group {
            if let error {
                ContentUnavailableView {
                    Label("Lesson unavailable", systemImage: "exclamationmark.triangle")
                } description: { Text(error) } actions: {
                    Button("Try again") { self.error = nil; html = nil; readerLoading = true; retry += 1 }
                }
            } else if let html {
                LessonWebView(html: html, theme: theme, pool: store.readerPool, speak: store.speak,
                              ready: { readerLoading = false }, failed: { readerLoading = false; self.error = $0 })
                    .allowsHitTesting(!readerLoading)
                    .accessibilityHidden(readerLoading)
                    .overlay {
                        if readerLoading {
                            ZStack {
                                theme.paper
                                ProgressView("Opening lesson…")
                            }.allowsHitTesting(false)
                        }
                    }
            } else { ProgressView("Opening lesson…") }
        }.background(theme.paper).navigationTitle(entry.headword).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { store.speak(entry.displayWord) } label: { Image(systemName: "speaker.wave.2") }.accessibilityLabel("Hear \(entry.displayWord)")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) { store.toggle(entry) }
                    } label: {
                        Image(systemName: store.contains(entry) ? "checkmark.circle.fill" : "plus.circle")
                            .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                    }
                        .accessibilityLabel(store.contains(entry) ? "Remove from deck" : "Add to deck")
                }
            }
            .task(id: retry) {
                do {
                    let source = try await store.readerSource(entry)
                    let gender = entry.nounGender
                    let rendered = await Task.detached(priority: .userInitiated) {
                        LessonHTML.make(template: source.template, json: source.json.replacingOccurrences(of: "<", with: "\\u003c"), gender: gender)
                    }.value
                    try Task.checkCancellation()
                    html = rendered
                } catch is CancellationError {
                    return
                } catch { readerLoading = false; self.error = error.localizedDescription }
            }
            .task(id: readerLoading) {
                guard readerLoading else { return }
                do { try await Task.sleep(for: .seconds(12)) } catch { return }
                guard readerLoading, error == nil else { return }
                readerLoading = false
                error = "This lesson is taking longer than expected to open. Please try again."
            }
            .onDisappear { store.stopAudio() }
    }
}
enum LessonHTML {
    static func make(template: String, json: String, gender: NounGender? = nil) -> String {
        var page = template.replacingOccurrences(of: "__LESSON_JSON__", with: json)
        // The lesson renderer remains the reference for optional sections and highlighting.
        // Remove remote fonts so every part of the reader works offline.
        page = page.replacingOccurrences(of: "<link[^>]*>", with: "", options: .regularExpression)
        page = page.replacingOccurrences(of: "</head>", with: """
        <style>
        :root { --paper:#f8f6f0; --ink:#202d27; --muted:#68736b; --blue:#275847; --rule:#dadfd7; --tint:#eaf0e8; --display:-apple-system,system-ui,sans-serif; --body:'Iowan Old Style',Georgia,serif; }
        @media(prefers-color-scheme:dark){ :root:not([data-theme=light]) { --paper:#121714; --ink:#e8eee7; --muted:#a6b5aa; --blue:#80bf9c; --rule:#33483b; --tint:#21382a; } }
        .bar,.finder,.picker,#json-view { display:none!important; }
        .sheet { padding:0 24px 48px; }
        .hero { border-radius:22px; margin-top:16px; background-image:none; background-color:var(--tint); padding:28px 22px; }
        .headword { font-family:var(--body); font-weight:500; font-size:clamp(2rem,9vw,3.7rem); overflow-wrap:anywhere; }
        h2 { font-family:var(--body); font-size:1.5rem; }
        .btn { border-radius:12px; min-height:44px; }
        .say-note { font-family:var(--display); }
        .sentences li { position:relative; padding-right:50px; }
        .listen { position:absolute; right:0; top:14px; background:var(--tint); border:0; border-radius:50%; width:44px; height:44px; color:var(--blue); font-size:20px; }
        input { font-size:16px!important; min-height:44px; }
        @media(prefers-reduced-motion:reduce){ * { animation:none!important; transition:none!important; } }
        </style></head>
        """)
        if let gender {
            page = page.replacingOccurrences(of: "</head>", with: """
            <style>
            .hero .headword,.hero .pos { color:var(--noun-\(gender.rawValue)); }
            .noun-key { display:flex;flex-wrap:wrap;gap:8px 18px;font:12px -apple-system,system-ui,sans-serif;margin:20px 0; }
            .noun-key span { white-space:nowrap; }
            </style></head>
            """)

        }
        // Also show the explanation and completed sentence after a fill answer.
        page = page.replacingOccurrences(of: "\"Richtig! \" + (q.fullAnswer || \"\")", with: "\"Richtig! \" + (q.fullAnswer || \"\") + \" \" + (q.explanation || \"\")")
        page = page.replacingOccurrences(of: "\"Not quite. Try again, or show the answer.\"", with: "\"Not quite. \" + (q.explanation || \"\") + \" \" + (q.fullAnswer || \"Try again, or show the answer.\")")
        page = page.replacingOccurrences(of: "\"Not quite. Try another one.\"", with: "\"Not quite. \" + (q.explanation || \"\") + \" \" + (q.fullAnswer || \"Try another one.\")")
        page = page.replacingOccurrences(of: "(q.explanation || \"\") :", with: "(q.explanation || \"\") + \" \" + (q.fullAnswer || \"\") :")
        page = page.replacingOccurrences(of: "</body>", with: """
        <script>
        var lessonData=JSON.parse(document.getElementById('lesson-data').textContent);
        var badge=document.createElement('p');
        badge.style='font:600 12px -apple-system;letter-spacing:1px;color:var(--muted);margin-bottom:14px';
        badge.textContent=lessonData.level+' · '+(lessonData.lessonType==='group'?'WORD GROUP':lessonData.lessonType==='card'?'SHORT CARD':'FULL LESSON');
        document.querySelector('.hero').prepend(badge);
        window.replayWordAnimation=function(){
          var segments=document.querySelectorAll('.hero .seg.stretch,.hero .seg.arrive,.hero .seg.release,.hero .seg.release-cue,.hero .seg.rise,.hero .seg.turn');
          segments.forEach(function(segment){segment.style.animation='none'});
          void document.querySelector('.hero').offsetWidth;
          requestAnimationFrame(function(){requestAnimationFrame(function(){
            segments.forEach(function(segment){segment.style.animation=''})
          })});
        };
        if(document.querySelector('.hero .seg.stretch,.hero .seg.arrive,.hero .seg.release,.hero .seg.release-cue,.hero .seg.rise,.hero .seg.turn')){
          var hero=document.querySelector('.hero');
          hero.style.cursor='pointer';
          hero.setAttribute('role','button');
          hero.setAttribute('tabindex','0');
          hero.setAttribute('aria-label',lessonData.word.headword+' word banner');
          hero.setAttribute('aria-description','Activate to replay the word animation');
          hero.onclick=window.replayWordAnimation;
          hero.onkeydown=function(event){
            if(event.key==='Enter'||event.key===' '){event.preventDefault();window.replayWordAnimation()}
          };
        }
        document.querySelectorAll('.sentences li').forEach(function(row){
          var text=row.querySelector('.de').textContent;
          var b=document.createElement('button'); b.className='listen';
          b.innerHTML='<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M11 5 6 9H3v6h3l5 4V5Z"/><path d="M15 8a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14"/></svg>';
          b.setAttribute('aria-label','Hear: '+text);
          b.onclick=function(){window.webkit.messageHandlers.speak.postMessage(text)};
          row.appendChild(b);
        });
        </script></body>
        """)
        if gender != nil {
            page = page.replacingOccurrences(of: "var badge=document.createElement('p');", with: """
            var key=document.createElement('div');key.className='noun-key';
            key.setAttribute('aria-label','Noun colors: der masculine blue, die feminine red, das neuter green');
            key.innerHTML='<span style="color:var(--noun-masculine)">● der · masculine</span><span style="color:var(--noun-feminine)">● die · feminine</span><span style="color:var(--noun-neuter)">● das · neuter</span>';
            document.querySelector('.hero').after(key);
            var badge=document.createElement('p');
            """)
        }
        return page
    }
}
/// Keep one idle reader ready, without sharing a mounted view between navigation stacks.
@MainActor final class LessonWebViewPool {
    private var idle: WKWebView?
    func prepare() {
        guard idle == nil else { return }
        let web = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        web.isOpaque = false
        web.backgroundColor = .clear
        web.loadHTMLString("<!doctype html><html><body></body></html>", baseURL: nil)
        idle = web
    }
    func acquire() -> WKWebView {
        if let web = idle { idle = nil; web.stopLoading(); return web }
        let web = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        web.isOpaque = false
        web.backgroundColor = .clear
        return web
    }
    func recycle(_ web: WKWebView) {
        web.stopLoading()
        web.navigationDelegate = nil
        web.configuration.userContentController.removeScriptMessageHandler(forName: "speak")
        guard idle == nil else { return }
        // Stop old timers and discard lesson content while retaining the warm browser.
        web.loadHTMLString("<!doctype html><html><body></body></html>", baseURL: nil)
        idle = web
    }
    func clear() { idle?.stopLoading(); idle = nil }
}

struct LessonWebView: UIViewRepresentable {
    let html: String
    let theme: AppTheme
    let pool: LessonWebViewPool
    let speak: (String) -> Void
    let ready: () -> Void
    let failed: (String) -> Void
    func makeCoordinator() -> Coordinator {
        Coordinator(theme: theme, pool: pool, speak: speak, ready: ready, failed: failed)
    }
    func makeUIView(context: Context) -> WKWebView {
        let web = pool.acquire()
        web.configuration.userContentController.add(context.coordinator, name: "speak")
        web.scrollView.setContentOffset(.zero, animated: false)
        web.navigationDelegate = context.coordinator
        let styledHTML = html.replacingOccurrences(of: "<html lang=\"en\">", with: "<html lang=\"en\" style=\"\(theme.css)\">")
        context.coordinator.html = styledHTML
        context.coordinator.navigation = web.loadHTMLString(styledHTML, baseURL: nil)
        return web
    }
    func updateUIView(_ web: WKWebView, context: Context) {
        context.coordinator.theme = theme
        context.coordinator.applyTheme(to: web)
    }
    static func dismantleUIView(_ web: WKWebView, coordinator: Coordinator) {
        coordinator.pool.recycle(web)
    }
    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let speak: (String) -> Void
        var theme: AppTheme
        let pool: LessonWebViewPool
        let ready: () -> Void
        let failed: (String) -> Void
        var html = ""
        var navigation: WKNavigation?
        private var recoveredProcess = false
        private var appliedTheme: AppTheme?
        init(theme: AppTheme, pool: LessonWebViewPool, speak: @escaping (String) -> Void,
             ready: @escaping () -> Void, failed: @escaping (String) -> Void) {
            self.theme = theme; self.pool = pool; self.speak = speak
            self.ready = ready; self.failed = failed
        }
        func applyTheme(to web: WKWebView, force: Bool = false) {
            guard force || appliedTheme != theme else { return }
            appliedTheme = theme
            guard let data = try? JSONEncoder().encode(theme.css), let css = String(data: data, encoding: .utf8) else { return }
            web.evaluateJavaScript("document.documentElement.style.cssText = " + css, completionHandler: nil)
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard navigation === self.navigation else { return }
            ready()
            applyTheme(to: webView, force: true)
            webView.evaluateJavaScript("if(window.replayWordAnimation){window.replayWordAnimation()}", completionHandler: nil)
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard navigation === self.navigation else { return }
            report(error)
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            guard navigation === self.navigation else { return }
            report(error)
        }
        private func report(_ error: Error) {
            guard (error as NSError).code != NSURLErrorCancelled else { return }
            failed("The lesson reader couldn’t open this page. Please try again.")
        }
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            guard !recoveredProcess else {
                failed("The lesson reader stopped unexpectedly. Please try again.")
                return
            }
            recoveredProcess = true
            navigation = webView.loadHTMLString(html, baseURL: nil)
        }
        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            if let text = message.body as? String { speak(text) }
        }
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(action.navigationType == .linkActivated ? .cancel : .allow)
        }
    }
}
