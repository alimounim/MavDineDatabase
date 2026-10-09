// Filter + sort for every results grid, and Ctrl+Enter in the SQL console.

document.querySelectorAll("input.filter").forEach(function (box) {
  var table = document.getElementById(box.dataset.grid);
  var counter = document.querySelector('.rowcount[data-grid="' + box.dataset.grid + '"]');
  if (!table) return;
  box.addEventListener("input", function () {
    var q = box.value.trim().toLowerCase(), shown = 0, rows = table.tBodies[0].rows;
    for (var i = 0; i < rows.length; i++) {
      var hit = !q || rows[i].textContent.toLowerCase().indexOf(q) >= 0;
      rows[i].style.display = hit ? "" : "none";
      if (hit) shown++;
    }
    if (counter) counter.textContent = (q ? shown + " of " + rows.length : rows.length) + " row(s)";
  });
});

function cellValue(row, i) {
  var cell = row.cells[i];
  var first = cell ? (cell.firstChild && cell.firstChild.nodeType === 3 ? cell.firstChild.textContent : cell.textContent) : "";
  return first.trim();
}

document.querySelectorAll("table.sortable").forEach(function (table) {
  var heads = table.tHead.rows[0].cells;
  Array.prototype.forEach.call(heads, function (th, i) {
    if (th.classList.contains("actions")) return;
    th.addEventListener("click", function () {
      var asc = !th.classList.contains("asc");
      Array.prototype.forEach.call(heads, function (h) { h.classList.remove("asc", "desc"); });
      th.classList.add(asc ? "asc" : "desc");
      var body = table.tBodies[0];
      var rows = Array.prototype.slice.call(body.rows);
      rows.sort(function (a, b) {
        var x = cellValue(a, i), y = cellValue(b, i);
        var nx = parseFloat(x), ny = parseFloat(y);
        var cmp = (!isNaN(nx) && !isNaN(ny) && /^-?[\d.]+$/.test(x) && /^-?[\d.]+$/.test(y))
          ? nx - ny : x.localeCompare(y, undefined, { numeric: true, sensitivity: "base" });
        if (x === "" && y !== "") cmp = 1; else if (y === "" && x !== "") cmp = -1;   // empty (NULL) last
        return asc ? cmp : -cmp;
      });
      rows.forEach(function (r) { body.appendChild(r); });
    });
  });
});

var sqlform = document.getElementById("sqlform");
if (sqlform) {
  sqlform.querySelector("textarea").addEventListener("keydown", function (e) {
    if (e.key === "Enter" && (e.ctrlKey || e.metaKey)) { e.preventDefault(); sqlform.submit(); }
    if (e.key === "Tab") {                                   // Tab inserts spaces instead of leaving the box
      e.preventDefault();
      var t = e.target, s = t.selectionStart;
      t.value = t.value.slice(0, s) + "    " + t.value.slice(t.selectionEnd);
      t.selectionStart = t.selectionEnd = s + 4;
    }
  });
}

var onlyerr = document.getElementById("onlyerr");
if (onlyerr) onlyerr.addEventListener("change", function () {
  document.getElementById("scriptlog").classList.toggle("onlyerr", onlyerr.checked);
});

var hl = document.querySelector("tr.hl");
if (hl) hl.scrollIntoView({ block: "center" });
