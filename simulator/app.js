/* ═══════════════════════════════════════════════
   Center Information Display Simulator — app.js  v2
   ═══════════════════════════════════════════════ */

'use strict';

// ── Central state ──────────────────────────────
const AppState = {
  currentScreen: 'home',
  previousScreen: 'home',

  climate: {
    driverTemp: 22,
    passengerTemp: 21,
    fanSpeed: 2,
    ac: true,
    sync: false,
    defrost: false,
    recirculate: false,
    driverSeat: 'off',   // off | low | high
    passengerSeat: 'off',
  },

  media: {
    source: 'radio',
    trackIndex: 0,
    playing: true,
    volume: 50,
    muted: false,
  },

  phone: {
    bluetooth: false,
    inCall: false,
    callContact: '',
    callDuration: 0,
    dialBuffer: '',
    callTimer: null,
  },

  settings: {
    theme: 'dark',
    brightness: 80,
    language: 'en',
    units: 'metric',
    bluetooth: false,
    wifi: true,
  },

  camera: {
    view: 'rear',
    obstacle: 'clear',
  },
};

// ── Mock data ───────────────────────────────────
const TRACKS = [
  { name: 'Roadtrip Vibes', artist: 'Summer Beats', elapsed: '1:24', duration: '3:45' },
  { name: 'Night Drive', artist: 'Neon Pulse', elapsed: '0:00', duration: '4:12' },
  { name: 'Open Road', artist: 'The Wanderers', elapsed: '0:00', duration: '3:58' },
  { name: 'Sunset Highway', artist: 'Chrome Wave', elapsed: '0:00', duration: '5:01' },
];

const RADIO = [
  { name: 'Rock FM', detail: '93.5 FM' },
  { name: 'Pop Hits', detail: '98.2 FM' },
  { name: 'Jazz Lounge', detail: '104.7 FM' },
];

// ── Navigation ──────────────────────────────────
function navigateTo(screenId) {
  const prev = document.getElementById('screen-' + AppState.currentScreen);
  if (prev) { prev.classList.remove('active'); prev.classList.add('hidden'); }

  const next = document.getElementById('screen-' + screenId);
  if (!next) return;
  next.classList.remove('hidden');
  next.classList.add('active');

  AppState.previousScreen = AppState.currentScreen;
  AppState.currentScreen = screenId;

  const label = screenId.toUpperCase();
  document.getElementById('status-app-title').textContent = label;
  document.getElementById('nav-current-screen').textContent = label;
}

function navigateBack() {
  navigateTo(AppState.previousScreen);
}

// ── Clock ───────────────────────────────────────
function updateClock() {
  const n = new Date();
  const hh = String(n.getHours()).padStart(2, '0');
  const mm = String(n.getMinutes()).padStart(2, '0');
  document.getElementById('status-time').textContent = hh + ':' + mm;
}

// ── Home screen ─────────────────────────────────
function updateHomeDate() {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const n = new Date();
  const el = document.getElementById('home-date');
  if (el) el.textContent = days[n.getDay()] + ', ' + months[n.getMonth()] + ' ' + n.getDate();
}

function updateNowPlaying() {
  const s = AppState.media;
  let track, artist;
  if (s.source === 'radio') {
    const st = RADIO[s.trackIndex % RADIO.length];
    track = st.name; artist = st.detail;
  } else {
    const t = TRACKS[s.trackIndex % TRACKS.length];
    track = t.name; artist = t.artist;
  }
  const nt = document.getElementById('home-np-track');
  const na = document.getElementById('home-np-artist');
  if (nt) nt.textContent = track;
  if (na) na.textContent = artist;
}

// ── Climate ─────────────────────────────────────
function _formatTemp(celsius) {
  if (AppState.settings.units === 'imperial') {
    return Math.round((celsius * 9) / 5 + 32) + '°F';
  }
  return celsius + '°C';
}

function _renderClimateTemps() {
  const s = AppState.climate;
  document.getElementById('climate-temperature-value').textContent = _formatTemp(s.driverTemp);
  document.getElementById('climate-passenger-temp-value').textContent = _formatTemp(s.passengerTemp);
  const outdoor = document.getElementById('status-outdoor-temp');
  if (outdoor) outdoor.textContent = _formatTemp(18);
}

function adjustTemp(zone, delta) {
  const s = AppState.climate;
  if (zone === 'driver' || s.sync) {
    s.driverTemp = Math.min(30, Math.max(16, s.driverTemp + delta));
  }
  if (zone === 'passenger' || s.sync) {
    s.passengerTemp = Math.min(30, Math.max(16, s.passengerTemp + delta));
  }
  _renderClimateTemps();
}

function adjustFan(delta) {
  const s = AppState.climate;
  s.fanSpeed = Math.min(7, Math.max(0, s.fanSpeed + delta));
  document.getElementById('climate-fan-speed-value').textContent = s.fanSpeed;
  _renderFanBars(s.fanSpeed);
}

function _renderFanBars(speed) {
  document.querySelectorAll('.fb').forEach((bar, i) => {
    bar.classList.toggle('active', i < speed);
  });
}

function toggleClimate(feature) {
  const s = AppState.climate;
  s[feature] = !s[feature];
  const ids = { ac: 'climate-ac-toggle', sync: 'climate-sync-toggle', defrost: 'climate-defrost-toggle', recirculate: 'climate-recirculate-toggle' };
  const lbl = { ac: ['A/C ON', 'A/C OFF'], sync: ['SYNC ON', 'SYNC OFF'], defrost: ['DEFROST ON', 'DEFROST OFF'], recirculate: ['RECIRC ON', 'RECIRC OFF'] };
  const btn = document.getElementById(ids[feature]);
  btn.dataset.state = s[feature] ? 'on' : 'off';
  btn.textContent = s[feature] ? lbl[feature][0] : lbl[feature][1];
  if (feature === 'sync' && s[feature]) {
    s.passengerTemp = s.driverTemp;
    _renderClimateTemps();
  }
}

function toggleSeatHeat(zone) {
  const key = zone === 'driver' ? 'driverSeat' : 'passengerSeat';
  const id = zone === 'driver' ? 'climate-driver-seat-heat' : 'climate-passenger-seat-heat';
  const cycle = { off: 'low', low: 'high', high: 'off' };
  AppState.climate[key] = cycle[AppState.climate[key]];
  const btn = document.getElementById(id);
  btn.dataset.state = AppState.climate[key];
  btn.textContent = AppState.climate[key].toUpperCase();
}

// ── Media ────────────────────────────────────────
function renderTrack() {
  const s = AppState.media;
  if (s.source === 'radio') {
    const st = RADIO[s.trackIndex % RADIO.length];
    document.getElementById('media-track-name').textContent = st.name;
    document.getElementById('media-artist-name').textContent = 'FM Radio';
    document.getElementById('media-source-display').textContent = 'Radio FM · ' + st.detail;
  } else {
    const t = TRACKS[s.trackIndex % TRACKS.length];
    document.getElementById('media-track-name').textContent = t.name;
    document.getElementById('media-artist-name').textContent = t.artist;
    document.getElementById('media-source-display').textContent = s.source === 'bluetooth' ? 'Bluetooth Audio' : 'USB Drive';
    document.getElementById('media-elapsed-time').textContent = t.elapsed;
    document.getElementById('media-total-time').textContent = t.duration;
  }
  updateNowPlaying();
}

function setMediaSource(source) {
  AppState.media.source = source;
  AppState.media.trackIndex = 0;
  document.querySelectorAll('.source-tab').forEach(b => b.classList.remove('active'));
  document.getElementById('media-source-' + source).classList.add('active');
  renderTrack();
}

function mediaPlayPause() {
  const s = AppState.media;
  s.playing = !s.playing;
  const btn = document.getElementById('media-play-pause-button');
  btn.dataset.state = s.playing ? 'playing' : 'paused';
  document.getElementById('media-play-icon').style.display = s.playing ? 'none' : 'block';
  document.getElementById('media-pause-icon').style.display = s.playing ? 'block' : 'none';
}

function mediaNext() {
  const len = AppState.media.source === 'radio' ? RADIO.length : TRACKS.length;
  AppState.media.trackIndex = (AppState.media.trackIndex + 1) % len;
  renderTrack();
}

function mediaPrev() {
  const len = AppState.media.source === 'radio' ? RADIO.length : TRACKS.length;
  AppState.media.trackIndex = (AppState.media.trackIndex - 1 + len) % len;
  renderTrack();
}

function adjustVolume(delta) {
  const s = AppState.media;
  s.volume = Math.min(100, Math.max(0, s.volume + delta));
  const pct = s.volume + '%';
  document.getElementById('nav-volume-value').textContent = s.volume;
  document.getElementById('media-volume-value').textContent = s.volume;
  document.getElementById('media-volume-fill').style.width = pct;
}

function toggleMute() {
  const s = AppState.media;
  s.muted = !s.muted;
  const btn = document.getElementById('nav-mute-button');
  btn.dataset.state = s.muted ? 'muted' : 'unmuted';
  btn.textContent = s.muted ? 'Unmute' : 'Mute';
}

// ── Phone ────────────────────────────────────────
function toggleBluetooth() {
  const s = AppState.settings;
  s.bluetooth = !s.bluetooth;
  const state = s.bluetooth ? 'on' : 'off';
  const label = s.bluetooth ? 'ON' : 'OFF';
  _setBtn('settings-bluetooth-toggle', state, label);
  _setBtn('phone-bluetooth-toggle', state, 'Bluetooth: ' + label);
  const sb = document.getElementById('status-bluetooth');
  sb.dataset.state = state;
  sb.className = 'status-icon-wrap ' + (s.bluetooth ? 'status-on' : 'status-off');
}

function initiateCall(name, number) {
  if (!AppState.settings.bluetooth) {
    // Still allow call — just log warning (don't use alert in automation)
    console.warn('Bluetooth is off; initiating call anyway for test purposes.');
  }
  const s = AppState.phone;
  s.inCall = true; s.callContact = name; s.callDuration = 0;
  document.getElementById('phone-call-contact').textContent = name + '  ·  ' + number;
  document.getElementById('phone-call-duration').textContent = '0:00';
  document.getElementById('phone-call-status').classList.remove('hidden');
  s.callTimer = setInterval(() => {
    s.callDuration++;
    const m = Math.floor(s.callDuration / 60);
    const sc = String(s.callDuration % 60).padStart(2, '0');
    document.getElementById('phone-call-duration').textContent = m + ':' + sc;
  }, 1000);
}

function endCall() {
  clearInterval(AppState.phone.callTimer);
  AppState.phone.inCall = false;
  document.getElementById('phone-call-status').classList.add('hidden');
}

function dialDigit(digit) {
  AppState.phone.dialBuffer += digit;
  document.getElementById('phone-dial-display').textContent = AppState.phone.dialBuffer;
}

function clearDial() {
  AppState.phone.dialBuffer = AppState.phone.dialBuffer.slice(0, -1);
  document.getElementById('phone-dial-display').textContent = AppState.phone.dialBuffer;
}

function callDialed() {
  const num = AppState.phone.dialBuffer;
  if (num) initiateCall(num, num);
}

// ── Navigation GPS ───────────────────────────────
function searchDestination() {
  const val = document.getElementById('nav-destination-input').value.trim();
  if (!val) return;
  document.getElementById('nav-destination-display').textContent = val;
  document.getElementById('nav-eta-display').textContent = '18 min';
  document.getElementById('nav-distance-display').textContent = '12.4 km';
  document.getElementById('nav-turn-display').textContent = 'Turn right in 400 m';
  const arrow = document.getElementById('nav-turn-arrow');
  arrow.textContent = '→'; arrow.classList.remove('hidden');
}

// ── Camera ───────────────────────────────────────
function setCameraView(view) {
  AppState.camera.view = view;
  const labels = { rear: 'REAR VIEW', front: 'FRONT VIEW', '360': '360° VIEW' };
  document.getElementById('camera-feed').dataset.view = view;
  document.getElementById('camera-view-label').textContent = labels[view] || view.toUpperCase() + ' VIEW';
  document.querySelectorAll('.cam-tab').forEach(b => b.classList.remove('active'));
  document.getElementById('camera-view-' + view).classList.add('active');
}

function simulateObstacle(level) {
  AppState.camera.obstacle = level;
  const feed = document.getElementById('camera-feed');
  if (feed) feed.dataset.obstacle = level;
  const map = { clear: { state: 'clear', text: 'Clear' }, medium: { state: 'medium', text: '1.5 m' }, near: { state: 'near', text: '< 0.3 m' } };
  const info = map[level];
  ['sensor-rear-left', 'sensor-rear-center-left', 'sensor-rear-center-right', 'sensor-rear-right',
    'sensor-front-left', 'sensor-front-center-left', 'sensor-front-center-right', 'sensor-front-right']
    .forEach(id => { const el = document.getElementById(id); if (el) el.dataset.state = info.state; });
  document.getElementById('sensor-rear-distance').textContent = info.text;
  document.getElementById('sensor-front-distance').textContent = info.text;
}

// ── Settings ─────────────────────────────────────
function toggleTheme() {
  const s = AppState.settings;
  s.theme = s.theme === 'dark' ? 'light' : 'dark';
  document.documentElement.dataset.theme = s.theme;
  const btn = document.getElementById('settings-theme-toggle');
  btn.dataset.state = s.theme;
  btn.textContent = s.theme === 'dark' ? 'Dark Mode' : 'Light Mode';
}

function adjustBrightness(delta) {
  const s = AppState.settings;
  s.brightness = Math.min(100, Math.max(10, s.brightness + delta));
  document.getElementById('settings-brightness-value').textContent = s.brightness + '%';
  document.getElementById('screens-container').style.filter = 'brightness(' + (s.brightness / 100) + ')';
}

const I18N = {
  en: { welcome: 'Welcome', settings: 'Settings', theme: 'Display Theme', brightness: 'Brightness', language: 'Language', units: 'Units', version: 'System Version' },
  de: { welcome: 'Willkommen', settings: 'Einstellungen', theme: 'Anzeigedesign', brightness: 'Helligkeit', language: 'Sprache', units: 'Einheiten', version: 'Systemversion' },
  fr: { welcome: 'Bienvenue', settings: 'Paramètres', theme: 'Thème', brightness: 'Luminosité', language: 'Langue', units: 'Unités', version: 'Version système' },
  tr: { welcome: 'Hoş Geldiniz', settings: 'Ayarlar', theme: 'Tema', brightness: 'Parlaklık', language: 'Dil', units: 'Birimler', version: 'Sistem Sürümü' },
};

function changeLanguage(lang) {
  AppState.settings.language = lang;
  document.documentElement.lang = lang;
  const t = I18N[lang] || I18N.en;
  const welcome = document.querySelector('#screen-home .home-welcome');
  if (welcome) welcome.textContent = t.welcome;
  const settingsTitle = document.querySelector('#screen-settings .screen-header h2');
  if (settingsTitle) settingsTitle.textContent = t.settings;
  const rowLabels = {
    'settings-theme-row': t.theme,
    'settings-brightness-row': t.brightness,
    'settings-language-row': t.language,
    'settings-units-row': t.units,
    'settings-version-row': t.version,
  };
  Object.entries(rowLabels).forEach(([rowId, label]) => {
    const el = document.querySelector('#' + rowId + ' .settings-label');
    if (el) el.textContent = label;
  });
}

function toggleUnits() {
  const s = AppState.settings;
  s.units = s.units === 'metric' ? 'imperial' : 'metric';
  const btn = document.getElementById('settings-units-toggle');
  btn.dataset.state = s.units;
  btn.textContent = s.units === 'metric' ? 'Metric' : 'Imperial';
  _updateVehicleUnits();
  _renderClimateTemps();
}

function toggleWifi() {
  const s = AppState.settings;
  s.wifi = !s.wifi;
  const st = s.wifi ? 'on' : 'off';
  _setBtn('settings-wifi-toggle', st, s.wifi ? 'ON' : 'OFF');
  const sb = document.getElementById('status-wifi');
  sb.dataset.state = st;
  sb.className = 'status-icon-wrap ' + (s.wifi ? 'status-on' : 'status-off');
}

// ── Helpers ──────────────────────────────────────
function _setBtn(id, state, label) {
  const btn = document.getElementById(id);
  if (!btn) return;
  btn.dataset.state = state;
  btn.textContent = label;
}

function _updateVehicleUnits() {
  const m = AppState.settings.units === 'metric';
  document.getElementById('vehicle-speed-value').textContent = m ? '0 km/h' : '0 mph';
  document.getElementById('vehicle-trip-value').textContent = m ? '142.3 km' : '88.4 mi';
  document.getElementById('vehicle-odometer-value').textContent = m ? '24,381 km' : '15,149 mi';
}

// ── Init ─────────────────────────────────────────
function init() {
  updateClock();
  setInterval(updateClock, 1000);
  updateHomeDate();
  renderTrack();
  _renderFanBars(AppState.climate.fanSpeed);
  _renderClimateTemps();
  const navInput = document.getElementById('nav-destination-input');
  if (navInput) {
    navInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') searchDestination();
    });
  }
}

document.addEventListener('DOMContentLoaded', init);
