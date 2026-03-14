const grid = document.getElementById("plugin-grid");
const search = document.getElementById("search");
const meta = document.getElementById("meta");

let plugins = [];

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
  try {
    const res = await fetch("plugins.json", { cache: "no-store" });
    const data = await res.json();
    plugins = Array.isArray(data.plugins) ? data.plugins : [];
    render(plugins);
    const count = plugins.length;
    const stamp = data.generated_at ? `Updated ${data.generated_at}` : "Freshly generated";
    meta.textContent = `${count} plugin packs | ${stamp}`;
  } catch (err) {
    meta.textContent = "Failed to load plugins.json.";
    console.error(err);
  }
}

search.addEventListener("input", (event) => {
  filterPlugins(event.target.value);
});

loadPlugins();
