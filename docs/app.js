const groups = [
  { title: '작업 시작', items: ['start', 'init', 'detect', 'route', 'inspect', 'adapter', 'doctor', 'status'] },
  { title: '검사·증거', items: ['check', 'test', 'review', 'report', 'evidence', 'handoff'] },
  { title: '배포·운영', items: ['pipeline', 'deploy', 'airc', 'release-check', 'safe-push', 'session', 'journal'] }
];

const commands = [
  ['start', '작업 시작 컨텍스트', '프로젝트를 처음 열었을 때 방언, runner, entrypoint, 테스트, Git 상태를 확인합니다.', 'fl-tools start .', '코딩 전에 먼저 실행하세요. READY=YES가 작업 시작 신호입니다.'],
  ['init', '작업 기록 초기화', '프로젝트에 .freelang/worklog.md 작업 기록 공간을 만듭니다.', 'fl-tools init .', '기존 파일은 덮어쓰지 않고 필요한 디렉터리만 준비합니다.'],
  ['detect', '프로젝트·방언 감지', 'AFJ, FX, AIA, AIRC, Script, Front 계열과 연결된 runner를 찾습니다.', 'fl-tools detect .', 'AIRC는 airc.fl 또는 SPEC.airc와 .airc 파일을 기준으로 감지합니다.'],
  ['route', '실행 경로 요약', '현재 프로젝트의 개발, 테스트, 검사 명령과 runner를 요약합니다.', 'fl-tools route .', 'AI가 프로젝트별 명령을 추측하지 않도록 쓰는 명령입니다.'],
  ['inspect', '통합 프로젝트 점검', 'detect, route, doctor, status를 한 번에 실행합니다.', 'fl-tools inspect .', '새 저장소에 들어갔을 때 전체 상태를 빠르게 확인합니다.'],
  ['adapter', 'runner 연결 상태', 'AFJ, FX, AIA, AIRC, Script, Front 어댑터가 실제로 연결됐는지 확인합니다.', 'fl-tools adapter list .', 'ADAPTER_*=BLOCKED는 해당 환경에 runner가 없다는 뜻입니다.'],
  ['doctor', '기본 건강검진', 'runner, Git 저장소, 테스트 디렉터리, manifest와 공통 도구를 검사합니다.', 'fl-tools doctor .', '실행 가능한 프로젝트인지 먼저 확인할 때 사용합니다.'],
  ['status', '현재 상태', '방언, Git, release, test, selfhost/cold boot 상태를 출력합니다.', 'fl-tools status .', '검증되지 않은 상태는 PASS 대신 UNRESOLVED로 남습니다.'],
  ['check', '문법·기본 검사', '프로젝트 방언에 맞는 소스 검사와 테스트 검사를 실행합니다.', 'fl-tools check .', 'AIRC는 연결된 v11 runner로 루트 .fl 파일을 검사합니다.'],
  ['test', '프로젝트 테스트', '현재 방언에 맞는 테스트 runner를 자동 선택해 실행합니다.', 'fl-tools test .', 'tests/**/*.test.fl 규약과 프로젝트별 기존 runner를 우선 사용합니다.'],
  ['review', '변경사항 전체 검토', 'check, test, lint, build, diff check, 생성물 오염, 계약 drift를 검사합니다.', 'fl-tools review .', 'REVIEW=PASS가 아니면 deploy로 넘어가지 않습니다.'],
  ['report', '완료 보고서', '상태와 review 결과를 사람이 읽는 보고서 형식으로 출력합니다.', 'fl-tools report .', '작업 결과를 사용자나 다음 에이전트에게 전달할 때 사용합니다.'],
  ['evidence', '검증 증거 JSON', '검증 결과, commit, Git 상태, 원시 출력과 exit code를 JSON으로 보존합니다.', 'fl-tools evidence --json .', 'CI나 AI 인수인계에서 기계적으로 읽을 증거입니다.'],
  ['handoff', '작업 인수인계', '다음 작업자를 위한 .freelang/handoff.md를 생성합니다.', 'fl-tools handoff .', '현재 프로젝트와 최신 report를 다음 세션에 넘깁니다.'],
  ['pipeline', '전체 작업 파이프라인', 'init → inspect → review → report → handoff를 순서대로 실행합니다.', 'fl-tools pipeline .', '기본값은 deploy와 push를 실행하지 않습니다.'],
  ['deploy', '계약 기반 배포', 'review, dirty worktree, deploy 계약, smoke, artifact hash를 확인합니다.', 'fl-tools deploy .', 'deploy.sh와 smoke.sh가 없으면 DEPLOY=BLOCKED입니다.'],
  ['airc', 'AIRC CLI 실행', 'AIRC 프로젝트의 airc.fl을 기존 FreeLang v11 runner로 실행합니다.', 'fl-tools airc . status', '예: status, search, graph, why. 오래된 절대 경로 오류는 숨기지 않습니다.'],
  ['release-check', '릴리즈 준비 검사', 'CHANGELOG, tag, worktree, artifact hash 등 릴리즈 기준을 점검합니다.', 'fl-tools release-check', '릴리즈를 만들기 전에 실행합니다.'],
  ['safe-push', '안전한 push 검사', '원격 브랜치와 현재 변경 상태를 확인하고, 명시적 push 전에는 상태만 검사합니다.', 'fl-tools safe-push --help', '자동 push를 수행하지 않아 실수 방지용으로 사용합니다.'],
  ['session', '개발 세션 조회', 'PM2, 포트, 로그 등 운영 세션 상태를 조회합니다.', 'fl-tools session status', '알 수 없는 서비스를 임의로 재시작하지 않습니다.'],
  ['journal', '작업 저널', '작업 시작과 결과를 .freelang/worklog.md에 기록합니다.', 'fl-tools journal show', '작업의 흐름과 판단을 남길 때 사용합니다.']
];

const byName = Object.fromEntries(commands.map(item => [item[0], item]));
const nav = document.querySelector('#nav');
const list = document.querySelector('#command-list');
const empty = document.querySelector('#empty-state');

function renderNav() {
  nav.innerHTML = groups.map(group => `<div class="nav-group"><div class="nav-title">${group.title}</div>${group.items.map(name => `<a class="nav-link" href="#cmd-${name}" data-nav="${name}">${name}</a>`).join('')}</div>`).join('');
}

function renderCommands(query = '') {
  const needle = query.trim().toLowerCase();
  const filtered = commands.filter(([name, title, description, usage, note]) => !needle || [name, title, description, usage, note].join(' ').toLowerCase().includes(needle));
  list.innerHTML = filtered.map(([name, title, description, usage, note]) => `<details class="command-card" id="cmd-${name}"><summary class="command-summary"><code>fl-tools ${name}</code><span>${title}</span><b>+</b></summary><div class="command-body"><div><h4>설명</h4><p>${description}</p></div><div><h4>사용법</h4><pre>${usage}</pre><p class="note">${note}</p></div></div></details>`).join('');
  empty.hidden = filtered.length > 0;
}

function showToast(message) {
  const toast = document.querySelector('#toast');
  toast.textContent = message; toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 1600);
}

renderNav(); renderCommands();
document.querySelector('#search').addEventListener('input', event => renderCommands(event.target.value));
document.addEventListener('click', event => {
  const copy = event.target.closest('[data-copy]');
  if (!copy) return;
  navigator.clipboard?.writeText(copy.dataset.copy).then(() => showToast('명령을 복사했어요')).catch(() => showToast(copy.dataset.copy));
});
document.querySelector('#theme-toggle').addEventListener('click', () => {
  const dark = document.documentElement.dataset.theme === 'dark';
  document.documentElement.dataset.theme = dark ? '' : 'dark';
  localStorage.setItem('fl-theme', dark ? 'light' : 'dark');
});
if (localStorage.getItem('fl-theme') === 'dark') document.documentElement.dataset.theme = 'dark';

const observer = new IntersectionObserver(entries => entries.forEach(entry => {
  if (!entry.isIntersecting) return;
  const name = entry.target.id.replace('cmd-', '');
  document.querySelectorAll('[data-nav]').forEach(link => link.classList.toggle('active', link.dataset.nav === name));
}), { rootMargin: '-20% 0px -70% 0px' });
document.querySelectorAll('.command-card').forEach(card => observer.observe(card));
