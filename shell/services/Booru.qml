pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Booru image search. Site-agnostic from the start: gelbooru is primary
// (more permissive tag limits), danbooru secondary (faster, hard 2-tag cap).
Singleton {
    id: root

    property string site: Config.options.booru.site
    property string query: ""
    property int page: 0
    property var posts: []
    property bool loading: false
    property string error: ""

    // Verified 2026-08-30:
    //   safebooru, yande.re  -> work with no credentials
    //   gelbooru             -> HTTP 401 without api_key + user_id
    //   danbooru             -> Cloudflare challenge unless login + api_key are sent
    // Credentials, when present in config, are appended automatically.
    readonly property var endpoints: ({
        "safebooru": p => `https://safebooru.org/index.php?page=dapi&s=post&q=index&json=1&limit=${p.limit}&pid=${p.page}&tags=${p.tags}`,
        "yandere":   p => `https://yande.re/post.json?limit=${p.limit}&page=${p.page + 1}&tags=${p.tags}`,
        "gelbooru":  p => `https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&limit=${p.limit}&pid=${p.page}&tags=${p.tags}`
                          + credsFor("gelbooru"),
        "danbooru":  p => `https://danbooru.donmai.us/posts.json?limit=${p.limit}&page=${p.page + 1}&tags=${p.tags}`
                          + credsFor("danbooru")
    })

    readonly property var needsCreds: ["gelbooru", "danbooru"]

    function credsFor(which) {
        const c = (Config.options.booru.credentials ?? {})[which];
        if (!c) return "";
        if (which === "gelbooru" && c.apiKey && c.userId)
            return `&api_key=${encodeURIComponent(c.apiKey)}&user_id=${encodeURIComponent(c.userId)}`;
        if (which === "danbooru" && c.login && c.apiKey)
            return `&login=${encodeURIComponent(c.login)}&api_key=${encodeURIComponent(c.apiKey)}`;
        return "";
    }

    readonly property bool siteUsable: !needsCreds.includes(site) || credsFor(site) !== ""

    function buildTags() {
        const raw = query.trim().split(/\s+/).filter(t => t !== "");
        const black = Config.options.booru.blacklistEnabled
            ? (Config.options.booru.blacklist ?? []).map(t => "-" + t) : [];
        return encodeURIComponent([...raw, ...black].join(" "));
    }

    function search(reset) {
        if (reset) { page = 0; posts = []; }
        error = "";
        if (!siteUsable) {
            error = site + " needs an API key — add it in config";
            loading = false;
            return;
        }
        loading = true;
        const url = endpoints[site]({ limit: Config.options.booru.pageSize, page: page, tags: buildTags() });
        fetch.command = ["curl", "-sL", "--max-time", "15",
                         "-H", "User-Agent: ashura-shell/1.0", url];
        fetch.running = true;
    }
    function more() { page++; search(false); }

    // Normalises the two response shapes into one list.
    function ingest(text) {
        let data;
        try { data = JSON.parse(text); } catch (e) { error = "bad response"; return; }
        // gelbooru wraps in {post: [...]}, danbooru returns a bare array
        const arr = Array.isArray(data) ? data : (data.post ?? data.posts ?? []);
        const mapped = arr.map(p => ({
            id: p.id,
            preview: p.preview_url ?? p.preview_file_url ?? "",
            sample: p.sample_url ?? p.large_file_url ?? p.file_url ?? "",
            full: p.file_url ?? p.large_file_url ?? "",
            tags: p.tags ?? p.tag_string ?? "",
            rating: p.rating ?? "?"
        })).filter(p => p.preview !== "" && p.full !== "");
        if (arr.length > 0 && mapped.length === 0)
            error = "results had no usable image urls";
        posts = page === 0 ? mapped : [...posts, ...mapped];
        if (mapped.length === 0 && page === 0) error = "no results";
    }

    Process {
        id: fetch
        onExited: root.loading = false
        stdout: StdioCollector { onStreamFinished: root.ingest(text) }
    }

    // download to the wallpaper dir, then optionally apply
    function download(post, apply) {
        const dir = Config.options.wallpaper.dir.replace("~", Quickshell.env("HOME"));
        const ext = post.full.split(".").pop().split("?")[0];
        const out = `${dir}/booru-${site}-${post.id}.${ext}`;
        const cmd = apply
            ? `curl -sL --max-time 60 -o '${out}' '${post.full}' && ${Quickshell.env("HOME")}/.config/ashura/bin/set-theme '${out}'`
            : `curl -sL --max-time 60 -o '${out}' '${post.full}'`;
        Quickshell.execDetached(["sh", "-c", cmd]);
    }
}
