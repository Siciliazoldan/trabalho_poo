'use strict';
const $ = selector => document.querySelector(selector);
const esc = value => String(value).replace(/[&<>"']/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]));
const stages = ['Aberta','Em andamento','Aguardando peça','Concluída'];
const models = [
  {name:'Laminador Universal 4 High',maker:'Siemag Demag',use:'Conformação de chapas de aço por laminação.'},
  {name:'CNC Vertical Variaxis',maker:'Mazak',use:'Usinagem de componentes em múltiplos eixos.'}
];
const seed = {
  assets:[
    {tag:'MQ-LAM-01',name:'Laminador Principal A',model:0,line:'Laminação 01',status:'Operando'},
    {tag:'MQ-CNC-05',name:'Centro de Usinagem 05',model:1,line:'Usinagem CNC 03',status:'Em manutenção'}
  ],
  orders:[
    {id:2,title:'Revisão do painel elétrico',tag:'MQ-CNC-05',owner:'Ana',priority:'Urgente',stage:'Aberta'},
    {id:1,title:'Lubrificação e inspeção preventiva',tag:'MQ-LAM-01',owner:'Marcos',priority:'Alta',stage:'Em andamento'}
  ]
};
const key = 'engrenar.prototipo.v1';
let data = structuredClone(seed), role = '', filter = '', messageTimer;
try {
  const saved = JSON.parse(localStorage.getItem(key));
  if (Array.isArray(saved?.assets) && Array.isArray(saved?.orders)) data = saved;
  role = sessionStorage.getItem(key) || '';
} catch {}
const manager = () => role === 'gestao';
const visibleOrders = () => data.orders.filter(o => manager() || o.owner === 'Marcos');
const option = (v,selected) => '<option'+(v===selected?' selected':'')+'>'+esc(v)+'</option>';
const options = (values,selected) => values.map(v=>option(v,selected)).join('');
const code = id => 'OS-'+String(id).padStart(4,'0');
function notify(message) {
  $('#aviso').textContent=message;
  clearTimeout(messageTimer);
  messageTimer=setTimeout(()=>$('#aviso').textContent='',4500);
}
function save() {
  try { localStorage.setItem(key,JSON.stringify(data)); notify('Alterações salvas.'); }
  catch { notify('Alterações disponíveis apenas enquanto esta página estiver aberta.'); }
}
function menu(open) {
  document.body.classList.toggle('nav-open',open);
  $('.hamburger').setAttribute('aria-expanded',String(open));
  $('.nav-backdrop').hidden=!open;
  $('#sidebar').inert=matchMedia('(max-width:760px)').matches && !open;
}
function heading(title,sub,action='') {
  return '<div class="page-heading"><div><h1>'+title+'</h1><p>'+sub+'</p></div>'+action+'</div>';
}
function table(orders) {
  const rows=orders.map(o=>'<tr><td><button class="table-link" data-order="'+Number(o.id)+'"><small>'+code(o.id)+'</small>'+esc(o.title)+'</button></td><td><span class="ref">'+esc(o.tag)+'</span></td><td>'+esc(o.owner)+'</td><td>'+esc(o.stage)+'</td></tr>').join('');
  return '<div class="table-wrap"><table><thead><tr><th>Ordem / atividade</th><th>Ativo</th><th>Responsável</th><th>Status</th></tr></thead><tbody>'+(rows||'<tr><td colspan="4" class="empty">Nenhuma ordem encontrada.</td></tr>')+'</tbody></table></div>';
}
function overview(title) {
  const orders=visibleOrders();
  const metrics=[['OS pendentes',orders.filter(o=>o.stage!=='Concluída').length],['Em andamento',orders.filter(o=>o.stage==='Em andamento').length],['OS concluídas',orders.filter(o=>o.stage==='Concluída').length]];
  if(manager()) metrics.unshift(['Ativos em operação',data.assets.filter(a=>a.status==='Operando').length+' / '+data.assets.length]);
  return heading(title,manager()?'Manutenção da sua indústria.':'Atividades atribuídas a Marcos.')+'<div class="metrics">'+metrics.map(([label,n])=>'<article class="metric"><div class="metric-label">'+label+'</div><strong>'+n+'</strong></article>').join('')+'</div><section class="paper flush"><div class="panel-title"><h2>Ordens recentes</h2><a class="link" href="#os">Ver todas</a></div>'+table(orders.slice(0,5))+'</section>';
}
function orderPage() {
  const orders=visibleOrders().filter(o=>[code(o.id),o.tag,o.title,o.owner,o.stage].join(' ').toLocaleLowerCase('pt-BR').includes(filter.toLocaleLowerCase('pt-BR')));
  return heading('Ordens de serviço','Consulte as atividades e acompanhe a execução.',manager()?'<button class="button" id="nova">Nova OS</button>':'')+'<form class="filters" id="busca"><label>Buscar ordem<input name="q" placeholder="Atividade, TAG ou status" value="'+esc(filter)+'"></label><button class="button secondary">Filtrar</button></form><section class="paper flush"><div class="panel-title"><h2>Ordens encontradas <span class="count">'+orders.length+'</span></h2></div>'+table(orders)+'</section>';
}
function assetsPage() {
  return heading('Ativos e saúde','Condição das máquinas instaladas.')+'<div class="prototype-grid">'+data.assets.map((a,i)=>'<article class="paper asset-card"><span class="ref">'+esc(a.tag)+'</span><h2>'+esc(a.name)+'</h2><p>'+esc(a.line)+' · '+esc(a.status)+'</p><div class="card-end"><button class="link" data-asset-orders="'+i+'">Consultar OS</button>'+(manager()?'<button class="link" data-asset="'+i+'">Alterar condição</button>':'')+'</div></article>').join('')+'</div>';
}
function libraryPage() {
  return heading('Biblioteca de máquinas','Modelos de referência da indústria.')+'<div class="prototype-grid">'+models.map((m,i)=>'<article class="paper asset-card"><span class="ref">'+m.maker+'</span><h2>'+m.name+'</h2><p>'+m.use+'</p><div class="card-end"><button class="link" data-install="'+i+'">Instalar ativo</button></div></article>').join('')+'</div>';
}
function render() {
  const signed=['gestao','operacao'].includes(role);
  $('#entrada').hidden=signed; $('#painel').hidden=!signed;
  document.body.className=signed?'app':'login-page';
  if(!signed) return;
  menu(false);
  const titles={inicio:manager()?'Visão geral':'Meu trabalho',os:'Ordens de serviço',ativos:'Ativos e saúde',biblioteca:'Biblioteca de máquinas'};
  let route=location.hash.slice(1);
  if(!Object.hasOwn(titles,route)||(!manager()&&route==='biblioteca')) route='inicio';
  $('#nome').textContent=manager()?'Roberto':'Marcos';
  $('#avatar').textContent=manager()?'R':'M';
  $('#cargo').textContent=manager()?'Gestor de manutenção':'Mecânico';
  $('.nav-link[href="#inicio"] span').textContent=titles.inicio;
  $('.nav-link[href="#biblioteca"]').hidden=!manager();
  document.querySelectorAll('.nav-link').forEach(a=>a.hash==='#'+route?a.setAttribute('aria-current','page'):a.removeAttribute('aria-current'));
  $('#caminho').textContent=titles[route];
  $('#conteudo').innerHTML=({inicio:()=>overview(titles.inicio),os:orderPage,ativos:assetsPage,biblioteca:libraryPage})[route]();
}
function dialog(title,fields,commit) {
  const modal=$('#modal');
  modal.innerHTML='<div class="dialog-head"><h2 id="titulo-modal">'+esc(title)+'</h2><button class="icon-button" aria-label="Fechar">×</button></div><form class="dialog-form">'+fields+'<button class="button">Salvar</button></form>';
  modal.querySelector('button').onclick=()=>modal.close();
  modal.querySelector('form').onsubmit=e=>{
    e.preventDefault();
    if(commit(Object.fromEntries(new FormData(e.target)))===false) return;
    modal.close(); save(); render();
  };
  modal.showModal();
}
const select = (label,name,values,current) => '<label>'+label+'<select name="'+name+'">'+options(values,current)+'</select></label>';
const input = (label,name,max) => '<label>'+label+'<input required maxlength="'+max+'" name="'+name+'" pattern=".*\\S.*"></label>';
$('#conteudo').onclick=e=>{
  const b=e.target.closest('button');
  if(!b) return;
  if(b.id==='nova' && manager()) {
    dialog('Nova ordem de serviço',input('Atividade','title',120)+select('Ativo','tag',data.assets.map(a=>a.tag))+select('Responsável','owner',['Marcos','Ana','Roberto'])+select('Prioridade','priority',['Média','Alta','Urgente']),v=>{
      const id=data.orders.reduce((n,o)=>Math.max(n,o.id),0)+1;
      data.orders.unshift({...v,title:v.title.trim(),id,stage:'Aberta'}); filter='';
    });
  } else if(b.hasAttribute('data-order')) {
    const o=visibleOrders().find(o=>o.id===Number(b.dataset.order));
    if(o) dialog(code(o.id)+' · '+o.title,'<p>'+esc(o.tag)+' · '+esc(o.owner)+' · Prioridade '+esc(o.priority)+'</p>'+select('Status','stage',stages,o.stage),v=>{o.stage=v.stage;});
  } else if(b.hasAttribute('data-asset-orders')) {
    filter=data.assets[b.dataset.assetOrders].tag; location.hash='os';
  } else if(b.hasAttribute('data-asset') && manager()) {
    const a=data.assets[b.dataset.asset];
    dialog(a.name,select('Condição','status',['Operando','Em manutenção','Parada','Desativada'],a.status),v=>{a.status=v.status;});
  } else if(b.hasAttribute('data-install') && manager()) {
    const i=Number(b.dataset.install);
    dialog('Instalar '+models[i].name,input('Nome do ativo','name',100)+input('TAG','tag',30)+input('Linha de produção','line',80),v=>{
      const tag=v.tag.trim().toUpperCase();
      if(data.assets.some(a=>a.tag===tag)){const field=$('#modal [name="tag"]');field.setCustomValidity('Essa TAG já está em uso.');field.reportValidity();field.oninput=()=>field.setCustomValidity('');return false;}
      data.assets.push({tag,name:v.name.trim(),line:v.line.trim(),model:i,status:'Operando'});
      location.hash='ativos';
    });
  }
};
$('#conteudo').onsubmit=e=>{if(e.target.id==='busca'){e.preventDefault();filter=e.target.q.value.trim();render();}};
$('#entrar').onsubmit=e=>{e.preventDefault();role=e.target.perfil.value;try{sessionStorage.setItem(key,role);}catch{}location.hash='inicio';render();};
$('#sair').onclick=()=>{role='';filter='';try{sessionStorage.removeItem(key);}catch{}location.hash='';render();};
$('.hamburger').onclick=()=>menu(true);
$('.menu-close').onclick=$('.nav-backdrop').onclick=()=>menu(false);
document.querySelector('nav').onclick=e=>{if(e.target.closest('a')){filter='';menu(false);render();}};
window.addEventListener('hashchange',render);
matchMedia('(max-width:760px)').addEventListener('change',()=>menu(false));
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&document.body.classList.contains('nav-open'))menu(false);});
render();
if(location.protocol==='file:') document.getElementById('abrir-mysql').href='config.html';
