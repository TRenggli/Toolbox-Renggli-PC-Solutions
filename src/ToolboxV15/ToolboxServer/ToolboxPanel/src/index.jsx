import React, { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

function App() {
  return React.createElement('div', { className: 'panel' },
    React.createElement('h1', null, 'Toolbox V15 Admin Panel'),
    React.createElement('p', null, 'Operational console — agents, jobs, modules, audit, and backup.'),
    React.createElement('nav', null,
      React.createElement('span', { className: 'badge' }, 'Agents'),
      React.createElement('span', { className: 'badge' }, 'Jobs'),
      React.createElement('span', { className: 'badge' }, 'Modules'),
      React.createElement('span', { className: 'badge' }, 'Audit'),
      React.createElement('span', { className: 'badge' }, 'Backup')
    )
  );
}

const rootEl = document.getElementById('root');
createRoot(rootEl).render(React.createElement(StrictMode, null, React.createElement(App)));