'use strict';
document.querySelectorAll('[data-open]').forEach(button => {
    button.addEventListener('click', () => document.getElementById(button.dataset.open)?.showModal());
});
document.querySelectorAll('[data-close]').forEach(button => {
    button.addEventListener('click', () => button.closest('dialog').close());
});
document.querySelectorAll('dialog').forEach(dialog => {
    dialog.addEventListener('click', event => {
        if (event.target !== dialog) return;
        const box = dialog.getBoundingClientRect();
        if (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom) dialog.close();
    });
    if (dialog.hasAttribute('data-reopen')) dialog.showModal();
});
const eye = document.getElementById('eye');
if (eye) {
    const pwd = document.getElementById('password');
    eye.addEventListener('click', () => {
        const show = pwd.type === 'password';
        pwd.type = show ? 'text' : 'password';
        eye.setAttribute('aria-pressed', String(show));
        eye.setAttribute('aria-label', show ? 'Ocultar senha' : 'Mostrar senha');
    });
    const login = document.getElementById('login');
    const remember = document.getElementById('remember');
    try {
        const saved = localStorage.getItem('engrenar.identificacao');
        if (saved && !login.value) login.value = saved;
        remember.checked = !!saved;
        remember.addEventListener('change', () => { if (!remember.checked) localStorage.removeItem('engrenar.identificacao'); });
        document.getElementById('login-form').addEventListener('submit', () => {
            if (remember.checked) localStorage.setItem('engrenar.identificacao', login.value.trim());
            else localStorage.removeItem('engrenar.identificacao');
        });
    } catch (_) { /* O acesso também funciona sem armazenamento local. */ }
}
const navButton = document.querySelector('[data-menu]');
if (navButton) {
    const sidebar = document.querySelector('.sidebar');
    const backdrop = document.querySelector('.nav-backdrop');
    const mobile = window.matchMedia('(max-width: 760px)');
    function menu(open, restoreFocus = true) {
        document.body.classList.toggle('nav-open', open);
        navButton.setAttribute('aria-expanded', String(open));
        sidebar.inert = mobile.matches && !open;
        backdrop.hidden = !open;
        if (open) sidebar.querySelector('.menu-close').focus();
        else if (restoreFocus && mobile.matches) navButton.focus();
    }
    navButton.addEventListener('click', () => menu(true));
    document.querySelector('.menu-close').addEventListener('click', () => menu(false));
    backdrop.addEventListener('click', () => menu(false));
    document.addEventListener('keydown', e => {
        if (!document.body.classList.contains('nav-open')) return;
        if (e.key === 'Escape') menu(false);
        if (e.key === 'Tab') {
            const focusable = [...sidebar.querySelectorAll('a,button')].filter(x=>x.offsetParent!==null);
            if (e.shiftKey && document.activeElement===focusable[0]) { e.preventDefault();focusable.at(-1).focus(); }
            if (!e.shiftKey && document.activeElement===focusable.at(-1)) { e.preventDefault();focusable[0].focus(); }
        }
    });
    mobile.addEventListener('change', () => menu(false,false));
    menu(false,false);
}
