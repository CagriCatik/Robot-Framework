const SESSION_KEY = 'bp_demo_session';
const USERS_KEY = 'bp_demo_users';
const ORDERS_KEY = 'bp_demo_orders';

const demoAccount = {
  email: 'demo@example.com',
  password: 'secret123'
};

const seedUsers = [
  { id: 'u-100', name: 'Max Mustermann', email: 'max@example.com', role: 'Admin', status: 'Aktiv' },
  { id: 'u-101', name: 'Erika Musterfrau', email: 'erika@example.com', role: 'Editor', status: 'Aktiv' },
  { id: 'u-102', name: 'Sam Beispiel', email: 'sam@example.com', role: 'Viewer', status: 'Gesperrt' }
];

const uiState = {
  editingUserId: null,
  userFilter: '',
  flash: ''
};

const app = document.querySelector('[data-testid="app-root"]');
const sidebar = document.querySelector('[data-testid="app-sidebar"]');

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function initials(name) {
  return name
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join('')
    .toUpperCase();
}

function readUsers() {
  const stored = window.localStorage.getItem(USERS_KEY);
  if (!stored) {
    writeUsers(seedUsers);
    return clone(seedUsers);
  }

  return JSON.parse(stored);
}

function writeUsers(users) {
  window.localStorage.setItem(USERS_KEY, JSON.stringify(users));
}

function readOrders() {
  return JSON.parse(window.localStorage.getItem(ORDERS_KEY) || '[]');
}

function writeOrders(orders) {
  window.localStorage.setItem(ORDERS_KEY, JSON.stringify(orders));
}

function isAuthenticated() {
  return window.localStorage.getItem(SESSION_KEY) === 'active';
}

function routeName() {
  return (window.location.hash.replace(/^#\/?/, '') || 'login').split('?')[0];
}

function goTo(route) {
  window.location.hash = `#/${route}`;
}

function showShell(route) {
  const authenticated = isAuthenticated();
  sidebar.classList.toggle('is-hidden', !authenticated);
  app.classList.toggle('main', authenticated);
  app.classList.toggle('auth-layout', !authenticated);

  document.querySelectorAll('[data-route]').forEach((button) => {
    const active = button.dataset.route === route;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-current', active ? 'page' : 'false');
  });
}

function wireNavigation() {
  document.querySelectorAll('[data-route]').forEach((button) => {
    button.onclick = () => goTo(button.dataset.route);
  });

  const logout = document.querySelector('[data-testid="nav-logout"]');
  logout.onclick = () => {
    window.localStorage.removeItem(SESSION_KEY);
    goTo('login');
  };
}

function render() {
  const route = routeName();
  wireNavigation();

  if (route === 'reset-password') {
    showShell(route);
    renderPasswordReset();
    return;
  }

  if (!isAuthenticated() && route !== 'login') {
    goTo('login');
    return;
  }

  showShell(route);

  if (route === 'login') {
    renderLogin();
  } else if (route === 'users') {
    renderUsers();
  } else if (route === 'checkout') {
    renderCheckout();
  } else {
    renderDashboard();
  }
}

function renderAuthVisual() {
  return `
    <section class="auth-visual" aria-label="Produktvorschau">
      <div>
        <p class="eyebrow">Robot Framework Tutorial</p>
        <h1>Professionelle Webtests an einer realistischen Admin-Oberflaeche.</h1>
      </div>
      <p>Die Demo-App zeigt stabile Selektoren, klare User-Flows und wartbare Page-Resources an einer Oberflaeche, die wie ein echtes internes Business-Tool aufgebaut ist.</p>
      <div class="product-preview" aria-hidden="true">
        <div class="preview-toolbar">
          <div class="preview-dots"><span></span><span></span><span></span></div>
          <span class="status">Live Demo</span>
        </div>
        <div class="preview-grid">
          <div class="preview-block">
            <span>Benutzer</span>
            <strong>3</strong>
          </div>
          <div class="preview-block">
            <span>Bestellungen</span>
            <strong>0</strong>
          </div>
        </div>
        <div class="preview-chart">
          <span style="height: 42%"></span>
          <span style="height: 58%"></span>
          <span style="height: 36%"></span>
          <span style="height: 76%"></span>
          <span style="height: 64%"></span>
          <span style="height: 88%"></span>
        </div>
      </div>
    </section>
  `;
}

function routeTitle(route) {
  const titles = {
    dashboard: 'Dashboard',
    users: 'Benutzerverwaltung',
    checkout: 'Checkout'
  };

  return titles[route] || 'Dashboard';
}

function renderAppPage(route, content) {
  app.innerHTML = `
    <div class="workspace">
      <header class="topbar">
        <div class="topbar-title">
          <p class="eyebrow">Demo Workspace</p>
          <strong>${routeTitle(route)}</strong>
        </div>
        <div class="topbar-tools">
          <label class="global-search" aria-label="Globale Suche">
            <span class="search-mark" aria-hidden="true"></span>
            <input type="search" placeholder="Suchen">
          </label>
          <button class="icon-button" type="button" aria-label="Benachrichtigungen">
            <span class="bell" aria-hidden="true"></span>
          </button>
          <span class="avatar" data-initials="DE" aria-label="Demo Benutzer"></span>
        </div>
      </header>
      ${content}
    </div>
  `;
}

function renderLogin() {
  app.innerHTML = `
    <div class="auth-page">
      ${renderAuthVisual()}
      <section class="auth-panel" aria-labelledby="login-title">
        <p class="eyebrow">Sicherer Zugang</p>
        <h1 id="login-title">Anmelden</h1>
        <p>Robot Demo Admin</p>
        <form class="form" data-testid="login-form">
          <div class="field">
            <label for="login-email">E-Mail</label>
            <input id="login-email" name="email" type="email" autocomplete="username" data-testid="login-email">
          </div>
          <div class="field">
            <label for="login-password">Passwort</label>
            <input id="login-password" name="password" type="password" autocomplete="current-password" data-testid="login-password">
          </div>
          <p class="message is-error is-hidden" data-testid="login-error">E-Mail oder Passwort ist falsch.</p>
          <button class="primary-button" type="submit" data-testid="login-submit">Einloggen</button>
          <button class="link-button" type="button" data-testid="forgot-password-link">Passwort vergessen?</button>
        </form>
      </section>
    </div>
  `;

  document.querySelector('[data-testid="login-form"]').addEventListener('submit', (event) => {
    event.preventDefault();
    const email = document.querySelector('[data-testid="login-email"]').value.trim();
    const password = document.querySelector('[data-testid="login-password"]').value;
    const error = document.querySelector('[data-testid="login-error"]');

    if (email === demoAccount.email && password === demoAccount.password) {
      window.localStorage.setItem(SESSION_KEY, 'active');
      goTo('dashboard');
      return;
    }

    error.classList.remove('is-hidden');
  });

  document.querySelector('[data-testid="forgot-password-link"]').addEventListener('click', () => {
    goTo('reset-password');
  });
}

function renderPasswordReset() {
  app.innerHTML = `
    <div class="auth-page">
      ${renderAuthVisual()}
      <section class="auth-panel" aria-labelledby="reset-title">
        <p class="eyebrow">Konto wiederherstellen</p>
        <h1 id="reset-title">Passwort zuruecksetzen</h1>
        <p>Wir senden einen Link an die hinterlegte E-Mail-Adresse.</p>
        <form class="form" data-testid="password-reset-form">
          <div class="field">
            <label for="reset-email">E-Mail</label>
            <input id="reset-email" name="email" type="email" data-testid="password-reset-email">
          </div>
          <p class="message is-success is-hidden" data-testid="password-reset-confirmation">Reset-Link wurde versendet.</p>
          <button class="primary-button" type="submit" data-testid="password-reset-submit">Reset-Link senden</button>
          <button class="link-button" type="button" data-testid="back-to-login">Zurueck zum Login</button>
        </form>
      </section>
    </div>
  `;

  document.querySelector('[data-testid="password-reset-form"]').addEventListener('submit', (event) => {
    event.preventDefault();
    document.querySelector('[data-testid="password-reset-confirmation"]').classList.remove('is-hidden');
  });

  document.querySelector('[data-testid="back-to-login"]').addEventListener('click', () => goTo('login'));
}

function renderDashboard() {
  const users = readUsers();
  const orders = readOrders();

  renderAppPage('dashboard', `
    <section class="page">
      <div class="page-title">
        <div>
          <h1 data-testid="dashboard-title">Dashboard</h1>
          <p data-testid="dashboard-subtitle">Uebersicht der Demo-Anwendung</p>
        </div>
        <div class="page-actions">
          <button class="secondary-button" type="button">Export</button>
          <button class="primary-button" type="button">Neuer Report</button>
        </div>
      </div>
      <div class="metrics">
        <article class="metric">
          <div class="metric-top">
            <span>Benutzer</span>
            <span class="metric-icon" aria-hidden="true"></span>
          </div>
          <strong data-testid="metric-users">${users.length}</strong>
          <span class="metric-trend">+12% aktiv</span>
        </article>
        <article class="metric">
          <div class="metric-top">
            <span>Bestellungen</span>
            <span class="metric-icon" aria-hidden="true"></span>
          </div>
          <strong data-testid="metric-orders">${orders.length}</strong>
          <span class="metric-trend">${orders.length > 0 ? '+1 heute' : 'bereit'}</span>
        </article>
        <article class="metric">
          <div class="metric-top">
            <span>Offene Hinweise</span>
            <span class="metric-icon" aria-hidden="true"></span>
          </div>
          <strong data-testid="metric-alerts">2</strong>
          <span class="metric-trend is-warning">Review noetig</span>
        </article>
        <article class="metric">
          <div class="metric-top">
            <span>Testabdeckung</span>
            <span class="metric-icon" aria-hidden="true"></span>
          </div>
          <strong>94%</strong>
          <span class="metric-trend">stabil</span>
        </article>
      </div>
      <div class="dashboard-grid">
        <section class="panel">
          <div class="panel-header">
            <div>
              <h2>Aktivitaet</h2>
              <p data-testid="dashboard-activity">Letzte Anmeldung erfolgreich.</p>
            </div>
            <span class="status">Live</span>
          </div>
          <div class="chart" aria-label="Nutzungsentwicklung">
            ${[42, 56, 48, 72, 63, 88, 76].map((height, index) => `
              <div class="chart-column">
                <span class="chart-bar" style="height: ${height}%"></span>
                <span>${['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][index]}</span>
              </div>
            `).join('')}
          </div>
        </section>
        <section class="panel">
          <div class="panel-header">
            <div>
              <h2>Naechste Aufgaben</h2>
              <p>Fokus auf wartbare User-Flows.</p>
            </div>
          </div>
          <ul class="task-list">
            <li class="task-item">
              <span class="activity-dot" aria-hidden="true"></span>
              <div><strong>Regression pruefen</strong><span>10 Robot Tests bereit</span></div>
            </li>
            <li class="task-item">
              <span class="activity-dot" aria-hidden="true"></span>
              <div><strong>Neue Benutzerrolle</strong><span>Selektoren bleiben zentral</span></div>
            </li>
            <li class="task-item">
              <span class="activity-dot" aria-hidden="true"></span>
              <div><strong>Checkout Flow</strong><span>Negative Tests vorhanden</span></div>
            </li>
          </ul>
        </section>
      </div>
    </section>
  `);
}

function renderUsers() {
  const users = readUsers();
  const editingUser = users.find((user) => user.id === uiState.editingUserId);
  const filter = uiState.userFilter.trim().toLowerCase();
  const visibleUsers = users.filter((user) => {
    return !filter || `${user.name} ${user.email} ${user.role}`.toLowerCase().includes(filter);
  });

  renderAppPage('users', `
    <section class="page">
      <div class="page-title">
        <div>
          <h1 data-testid="users-title">Benutzerverwaltung</h1>
          <p>Benutzer suchen, anlegen und pflegen.</p>
        </div>
        <div class="page-actions">
          <button class="secondary-button" type="button">Import</button>
          <button class="primary-button" type="button">Einladung senden</button>
        </div>
      </div>

      <section class="panel">
        <div class="panel-header">
          <div>
            <h2>${editingUser ? 'Benutzer bearbeiten' : 'Benutzer anlegen'}</h2>
            <p>Formularfelder sind bewusst mit stabilen Test-IDs versehen.</p>
          </div>
        </div>
        <form class="form form-grid" data-testid="user-form">
          <div class="field">
            <label for="user-name">Name</label>
            <input id="user-name" name="name" data-testid="user-name" value="${editingUser ? escapeHtml(editingUser.name) : ''}">
          </div>
          <div class="field">
            <label for="user-email">E-Mail</label>
            <input id="user-email" name="email" type="email" data-testid="user-email" value="${editingUser ? escapeHtml(editingUser.email) : ''}">
          </div>
          <div class="field">
            <label for="user-role">Rolle</label>
            <select id="user-role" name="role" data-testid="user-role">
              ${['Admin', 'Editor', 'Viewer'].map((role) => `
                <option value="${role}" ${editingUser && editingUser.role === role ? 'selected' : ''}>${role}</option>
              `).join('')}
            </select>
          </div>
          <div class="field">
            <label>&nbsp;</label>
            <button class="primary-button" type="submit" data-testid="user-submit">${editingUser ? 'Aenderungen speichern' : 'Benutzer speichern'}</button>
          </div>
          <p class="message is-error is-hidden" data-testid="user-form-error">Name und E-Mail sind Pflichtfelder.</p>
          <p class="message is-success ${uiState.flash ? '' : 'is-hidden'}" data-testid="user-success">${uiState.flash}</p>
          ${editingUser ? '<button class="secondary-button" type="button" data-testid="user-cancel-edit">Bearbeitung abbrechen</button>' : ''}
        </form>
      </section>

      <section class="panel">
        <div class="toolbar">
          <div>
            <h2>Benutzerliste</h2>
            <p class="message">Gefilterte Ansicht mit fachlichen Tabellen-Locators.</p>
          </div>
          <div class="search-group">
            <input aria-label="Benutzer suchen" value="${escapeHtml(uiState.userFilter)}" data-testid="user-search">
            <button class="secondary-button" type="button" data-testid="user-search-submit">Suchen</button>
            <button class="secondary-button" type="button" data-testid="user-search-clear">Zuruecksetzen</button>
          </div>
        </div>
        <div class="table-wrap">
          <table data-testid="user-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>E-Mail</th>
                <th>Rolle</th>
                <th>Status</th>
                <th>Aktionen</th>
              </tr>
            </thead>
            <tbody>
              ${visibleUsers.map((user) => `
                <tr data-testid="user-row-${user.id}">
                  <td>
                    <span class="identity-cell">
                      <span class="avatar" data-initials="${escapeHtml(initials(user.name))}" aria-hidden="true"></span>
                      <span>${escapeHtml(user.name)}</span>
                    </span>
                  </td>
                  <td>${escapeHtml(user.email)}</td>
                  <td><span class="role-pill">${escapeHtml(user.role)}</span></td>
                  <td><span class="status ${user.status === 'Gesperrt' ? 'is-locked' : ''}">${escapeHtml(user.status)}</span></td>
                  <td>
                    <div class="row-actions">
                      <button class="secondary-button" type="button" data-action="edit" data-id="${user.id}">Bearbeiten</button>
                      <button class="danger-button" type="button" data-action="delete" data-id="${user.id}">Loeschen</button>
                    </div>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </section>
    </section>
  `);

  document.querySelector('[data-testid="user-form"]').addEventListener('submit', (event) => {
    event.preventDefault();
    const name = document.querySelector('[data-testid="user-name"]').value.trim();
    const email = document.querySelector('[data-testid="user-email"]').value.trim();
    const role = document.querySelector('[data-testid="user-role"]').value;
    const error = document.querySelector('[data-testid="user-form-error"]');

    if (!name || !email) {
      error.classList.remove('is-hidden');
      return;
    }

    if (uiState.editingUserId) {
      writeUsers(users.map((user) => user.id === uiState.editingUserId ? { ...user, name, email, role } : user));
      uiState.editingUserId = null;
      uiState.flash = 'Benutzer wurde aktualisiert.';
    } else {
      writeUsers([
        ...users,
        { id: `u-${Date.now()}`, name, email, role, status: 'Aktiv' }
      ]);
      uiState.flash = 'Benutzer wurde gespeichert.';
    }

    renderUsers();
  });

  const cancel = document.querySelector('[data-testid="user-cancel-edit"]');
  if (cancel) {
    cancel.addEventListener('click', () => {
      uiState.editingUserId = null;
      uiState.flash = '';
      renderUsers();
    });
  }

  document.querySelector('[data-testid="user-search-submit"]').addEventListener('click', () => {
    uiState.userFilter = document.querySelector('[data-testid="user-search"]').value;
    renderUsers();
  });

  document.querySelector('[data-testid="user-search-clear"]').addEventListener('click', () => {
    uiState.userFilter = '';
    renderUsers();
  });

  document.querySelectorAll('[data-action="edit"]').forEach((button) => {
    button.addEventListener('click', () => {
      uiState.editingUserId = button.dataset.id;
      uiState.flash = '';
      renderUsers();
    });
  });

  document.querySelectorAll('[data-action="delete"]').forEach((button) => {
    button.addEventListener('click', () => {
      writeUsers(users.filter((user) => user.id !== button.dataset.id));
      uiState.flash = 'Benutzer wurde geloescht.';
      renderUsers();
    });
  });
}

function renderCheckout() {
  renderAppPage('checkout', `
    <section class="page">
      <div class="page-title">
        <div>
          <h1 data-testid="checkout-title">Checkout</h1>
          <p>Demo-Bestellung fuer einen klaren User-Flow.</p>
        </div>
      </div>
      <div class="checkout-grid">
        <section class="panel">
          <div class="panel-header">
            <div>
              <h2>Bestellung</h2>
              <p>Der Flow prueft Produktwahl, Menge, AGB und Abschlussmeldung.</p>
            </div>
          </div>
          <div class="checkout-products" aria-hidden="true">
            <div class="product-tile"><strong>Starter</strong><span>Basis-Funktionen</span></div>
            <div class="product-tile"><strong>Pro</strong><span>Team Workflows</span></div>
            <div class="product-tile"><strong>Enterprise</strong><span>Audit und SSO</span></div>
          </div>
          <form class="form" data-testid="checkout-form">
            <div class="field">
              <label for="checkout-product">Produkt</label>
              <select id="checkout-product" name="product" data-testid="checkout-product">
                <option>Starter Plan</option>
                <option>Pro Plan</option>
                <option>Enterprise Plan</option>
              </select>
            </div>
            <div class="field">
              <label for="checkout-quantity">Anzahl</label>
              <input id="checkout-quantity" name="quantity" type="number" min="1" value="1" data-testid="checkout-quantity">
            </div>
            <label class="checkbox-field" for="checkout-terms">
              <input id="checkout-terms" type="checkbox" data-testid="checkout-terms">
              AGB akzeptieren
            </label>
            <p class="message is-error is-hidden" data-testid="checkout-error">Die AGB muessen akzeptiert werden.</p>
            <p class="message is-success is-hidden" data-testid="checkout-success">Bestellung wurde abgeschlossen.</p>
            <button class="primary-button" type="submit" data-testid="checkout-submit">Bestellung abschliessen</button>
          </form>
        </section>
        <aside class="summary">
          <h2>Zusammenfassung</h2>
          <dl>
            <div><dt>Status</dt><dd data-testid="checkout-status">Entwurf</dd></div>
            <div><dt>Lieferung</dt><dd>Digital</dd></div>
            <div><dt>Zahlung</dt><dd>Demo</dd></div>
          </dl>
        </aside>
      </div>
    </section>
  `);

  document.querySelector('[data-testid="checkout-form"]').addEventListener('submit', (event) => {
    event.preventDefault();
    const acceptedTerms = document.querySelector('[data-testid="checkout-terms"]').checked;
    const error = document.querySelector('[data-testid="checkout-error"]');
    const success = document.querySelector('[data-testid="checkout-success"]');

    error.classList.add('is-hidden');
    success.classList.add('is-hidden');

    if (!acceptedTerms) {
      error.classList.remove('is-hidden');
      return;
    }

    const product = document.querySelector('[data-testid="checkout-product"]').value;
    const quantity = document.querySelector('[data-testid="checkout-quantity"]').value;
    writeOrders([...readOrders(), { product, quantity }]);
    document.querySelector('[data-testid="checkout-status"]').textContent = 'Abgeschlossen';
    success.classList.remove('is-hidden');
  });
}

window.addEventListener('hashchange', render);
window.addEventListener('DOMContentLoaded', render);
