const grid = document.getElementById("plugin-grid");
const search = document.getElementById("search");
const meta = document.getElementById("meta");

let plugins = [];

function normalizePayload(data, sourceLabel, sourceUrl) {
  let list = [];
  if (Array.isArray(data)) {
    list = data;
  } else if (data && Array.isArray(data.plugins)) {
    list = data.plugins;
  }
  return list.map((plugin) => ({
    ...plugin,
    source: sourceLabel || "Official",
    source_url: sourceUrl || "",
  }));
}

function createCard(plugin) {
  const card = document.createElement("div");
  card.className = "card";

  const title = document.createElement("div");
  title.className = "card-title";
  title.textContent = plugin.name || plugin.id || "Unnamed Plugin";

  const desc = document.createElement("div");
  desc.textContent = plugin.description || "No description provided.";

  const metaRow = document.createElement("div");
  metaRow.className = "card-meta";
  const language = document.createElement("span");
  language.className = "tag";
  language.textContent = (plugin.language || "unknown").toUpperCase();
  const version = document.createElement("span");
  version.className = "tag";
  version.textContent = `v${plugin.version || "1.0.0"}`;
  metaRow.appendChild(language);
  metaRow.appendChild(version);
  if (Array.isArray(plugin.tags)) {
    plugin.tags.slice(0, 3).forEach((tag) => {
      const el = document.createElement("span");
      el.className = "tag";
      el.textContent = tag;
      metaRow.appendChild(el);
    });
  }
  if (plugin.source) {
    const el = document.createElement("span");
    el.className = "tag";
    el.textContent = plugin.source;
    metaRow.appendChild(el);
  }

  const actions = document.createElement("div");
  actions.className = "card-actions";
  const download = document.createElement("a");
  download.className = "download";
  download.textContent = "Download Pack";
  download.href = plugin.pack_url || "#";
  download.setAttribute("download", "");
  const details = document.createElement("a");
  details.className = "details";
  details.textContent = "Repo";
  details.href = plugin.homepage || "#";
  details.target = "_blank";
  details.rel = "noreferrer";
  actions.appendChild(download);
  actions.appendChild(details);

  card.appendChild(title);
  card.appendChild(desc);
  card.appendChild(metaRow);
  card.appendChild(actions);

  return card;
}

function render(list) {
  grid.innerHTML = "";
  list.forEach((plugin) => {
    grid.appendChild(createCard(plugin));
  });
}

function filterPlugins(term) {
  const t = term.trim().toLowerCase();
  if (!t) {
    render(plugins);
    return;
  }
  const filtered = plugins.filter((plugin) => {
    const hay = `${plugin.id} ${plugin.name} ${plugin.language} ${(plugin.tags || []).join(" ")}`.toLowerCase();
    return hay.includes(t);
  });
  render(filtered);
}

async function loadPlugins() {
  const sources = [];
  let registry = null;
  try {
    const regRes = await fetch("registry.json", { cache: "no-store" });
    if (regRes.ok) {
      registry = await regRes.json();
    }
  } catch (err) {
    registry = null;
  }

  if (registry && Array.isArray(registry.sources)) {
    registry.sources.forEach((src) => {
      if (src && src.url) {
        sources.push({
          name: src.name || "Community",
          url: new URL(src.url, window.location.href).toString(),
        });
      }
    });
  }

  if (sources.length === 0) {
    sources.push({ name: "Official", url: new URL("plugins.json", window.location.href).toString() });
  }

  const merged = [];
  const seen = new Set();
  let errors = 0;

  for (const source of sources) {
    try {
      const res = await fetch(source.url, { cache: "no-store" });
      const data = await res.json();
      const items = normalizePayload(data, source.name, source.url);
      items.forEach((plugin) => {
        const key = plugin.id || `${plugin.name}-${source.name}`;
        if (seen.has(key)) return;
        seen.add(key);
        merged.push(plugin);
      });
    } catch (err) {
      errors += 1;
      console.warn(`Failed to load ${source.url}`, err);
    }
  }

  plugins = merged;
  render(plugins);
  const count = plugins.length;
  const stamp = registry && registry.generated_at ? `Updated ${registry.generated_at}` : "Freshly generated";
  meta.textContent = `${count} plugin packs | ${sources.length} sources | ${stamp}${errors ? ` | ${errors} errors` : ""}`;
}

search.addEventListener("input", (event) => {
  filterPlugins(event.target.value);
});

loadPlugins();
