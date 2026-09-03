// Maximized Window Gaps
//
// Insets maximized windows by GAP px on every side so a maximized window keeps
// a margin from the screen edges. Change GAP to resize the margin.
//
// Note: this does NOT keep a floating panel floating. KDE de-floats the panel
// whenever a window gets near it; that logic is compiled into plasmashell with
// no config knob, so it can't be disabled from here.
//
// Written for KWin 6 (tested on Plasma 6.6): KWin only applies a frameGeometry
// change when the whole rect is assigned as a plain object; in-place edits
// (`win.width -= n`) are silently ignored.

const GAP = 12;

let block = false;

function applyGap(win) {
    if (block || !win || !win.normalWindow || win.fullScreen) return;
    if (["plasmashell", "krunner"].includes(String(win.resourceClass))) return;

    const area = workspace.clientArea(KWin.MaximizeArea, win);
    const g = win.frameGeometry;

    // Only act when the window fills the maximize area, i.e. is maximized.
    const filled =
        Math.abs(g.width - area.width) < 1 && Math.abs(g.height - area.height) < 1;
    if (!filled) return;

    block = true;
    win.frameGeometry = {
        x: area.x + GAP,
        y: area.y + GAP,
        width: area.width - 2 * GAP,
        height: area.height - 2 * GAP,
    };
    block = false;
}

function watch(win) {
    if (!win) return;
    // Maximizing is async on Wayland: maximizedChanged can fire before the
    // geometry becomes full, so also react to the geometry change itself.
    win.maximizedChanged.connect(() => applyGap(win));
    win.frameGeometryChanged.connect(() => applyGap(win));
}

workspace.windowList().forEach(watch);
workspace.windowList().forEach(applyGap);
workspace.windowAdded.connect((win) => {
    watch(win);
    applyGap(win);
});
