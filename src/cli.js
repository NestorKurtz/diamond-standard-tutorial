#!/usr/bin/env node

// ============================================================
//  Diamond Standard Tutorial - Terminal Fun Edition
//  EIP-2535 erklaert mit Stil, Witz und ASCII-Diamanten
// ============================================================

const readline = require('readline');

// --- Farben fuer das Terminal (ANSI Escape Codes) ---
const c = {
  reset:   '\x1b[0m',
  bold:    '\x1b[1m',
  dim:     '\x1b[2m',
  blink:   '\x1b[5m',
  cyan:    '\x1b[36m',
  yellow:  '\x1b[33m',
  green:   '\x1b[32m',
  red:     '\x1b[31m',
  magenta: '\x1b[35m',
  blue:    '\x1b[34m',
  white:   '\x1b[37m',
  bgBlue:  '\x1b[44m',
  bgCyan:  '\x1b[46m',
};

// --- ASCII Art ---
const DIAMOND_BIG = `
${c.cyan}${c.bold}
                    /\\
                   /  \\
                  /    \\
                 /      \\
                /  ${c.yellow}*  *${c.cyan}  \\
               /  ${c.yellow}* ** *${c.cyan}  \\
              /  ${c.yellow}*  EIP *${c.cyan}  \\
             /  ${c.yellow}* 2535  *${c.cyan}  \\
            /  ${c.yellow}* Diamond *${c.cyan}  \\
           /  ${c.yellow}* Standard *${c.cyan}  \\
          /____${c.yellow}*________*${c.cyan}____\\
          \\                    /
           \\                  /
            \\                /
             \\              /
              \\            /
               \\          /
                \\        /
                 \\      /
                  \\    /
                   \\  /
                    \\/
${c.reset}`;

const DIAMOND_SMALL = `${c.cyan}${c.bold}  /\\  ${c.reset}`;
const DIAMOND_SM2   = `${c.cyan}${c.bold} /  \\ ${c.reset}`;
const DIAMOND_SM3   = `${c.cyan}${c.bold} \\  / ${c.reset}`;
const DIAMOND_SM4   = `${c.cyan}${c.bold}  \\/  ${c.reset}`;

const FACET_ART = `
${c.magenta}${c.bold}
    .-----.-----.-----.
    | Cut | Cut | Cut |    Facets = Einzelne Smart Contracts
    '-----'-----'-----'    die dem Diamanten Funktionen geben
    | Fn1 | Fn2 | Fn3 |
    '-----'-----'-----'
${c.reset}`;

const SPARKLE = `${c.yellow}*${c.reset}`;

// --- Witzige Diamond-Sprueche ---
const DIAMOND_JOKES = [
  "Warum nutzen Solidity-Devs den Diamond Standard? Weil ein einzelner Contract einfach nicht genug Facetten hat!",
  "Was sagt ein Diamond Proxy zum anderen? 'Du bist so facettenreich!'",
  "Diamond Standard: Weil dein Smart Contract es verdient, wie ein Juwel behandelt zu werden.",
  "Ein Diamond ist der beste Freund eines Blockchain-Devs. Upgradeability inklusive!",
  "Knock knock! - Wer ist da? - delegatecall. - delegatecall wer? - delegatecall deine Facets, der Diamond braucht neue Funktionen!",
  "Was ist der Unterschied zwischen einem echten Diamanten und EIP-2535? Der eine ist teuer, der andere spart Gas!",
  "Roses are red, Violets are blue, DiamondCut is upgradeable, and so can you!",
  "Mein Smart Contract hat 24.576 Bytes... Zeit fuer einen Diamond!",
];

// --- Diamond Standard Lektionen ---
const LESSONS = [
  {
    title: "Was ist der Diamond Standard (EIP-2535)?",
    icon: `${c.cyan}/\\${c.reset}`,
    content: `
${c.bold}${c.cyan}Der Diamond Standard${c.reset} ist ein Smart-Contract-Architekturmuster,
das es ermoeglicht, einen einzigen Contract-Endpunkt (den "Diamond")
mit beliebig vielen Implementierungs-Contracts ("Facets") zu verbinden.

${c.yellow}Kernidee:${c.reset} Ein Diamond ist ein Proxy-Contract, der Funktionsaufrufe
an verschiedene Facets weiterleitet (via ${c.green}delegatecall${c.reset}).

${c.bold}Vorteile:${c.reset}
  ${SPARKLE} Keine Contract-Size-Limits (24KB Problem geloest!)
  ${SPARKLE} Modulare, upgradeable Architektur
  ${SPARKLE} Gemeinsamer Storage ueber alle Facets
  ${SPARKLE} Einzelner Contract-Endpunkt fuer User
`
  },
  {
    title: "Die drei Kernkomponenten",
    icon: `${c.yellow}***${c.reset}`,
    content: `
${c.bold}1. Diamond (Proxy)${c.reset}
   Der Hauptvertrag. Hat eine ${c.green}fallback()${c.reset} Funktion,
   die alle Aufrufe per ${c.green}delegatecall${c.reset} weiterleitet.

${c.bold}2. DiamondCut Facet${c.reset}
   Ermoeglicht das Hinzufuegen, Ersetzen und Entfernen von Facets.
   Sozusagen der "Juwelier" des Diamanten.

${c.bold}3. DiamondLoupe Facet${c.reset}
   ${c.dim}(Loupe = Juwelierslupe)${c.reset}
   Erlaubt es, den Diamond zu inspizieren:
   Welche Facets gibt es? Welche Funktionen?

${FACET_ART}
`
  },
  {
    title: "Wie funktioniert delegatecall?",
    icon: `${c.green}->${c.reset}`,
    content: `
${c.green}delegatecall${c.reset} ist der Zaubertrick hinter dem Diamond.

Normaler ${c.red}call${c.reset}:
  Contract A ruft Contract B auf.
  ${c.dim}-> Code von B laeuft im Kontext von B${c.reset}
  ${c.dim}-> Storage von B wird geaendert${c.reset}

${c.green}delegatecall${c.reset}:
  Contract A ruft Contract B auf, ABER:
  ${c.bold}-> Code von B laeuft im Kontext von A!${c.reset}
  ${c.bold}-> Storage von A wird geaendert!${c.reset}

${c.yellow}Das bedeutet:${c.reset}
  Der Diamond (Proxy) hat den Storage.
  Die Facets liefern nur den Code.
  = Alles bleibt an einer Adresse!

${c.cyan}  Diamond ${c.white}--delegatecall--> ${c.magenta}Facet A
${c.cyan}    |                          ${c.magenta}(Code)
${c.cyan}  [Storage]      ${c.dim}Storage bleibt im Diamond!${c.reset}
`
  },
  {
    title: "Diamond Storage Pattern",
    icon: `${c.blue}[]${c.reset}`,
    content: `
Das ${c.bold}Diamond Storage Pattern${c.reset} verhindert Storage-Kollisionen
zwischen verschiedenen Facets.

${c.yellow}Problem:${c.reset} Wenn Facet A und Facet B beide slot 0 nutzen,
ueberschreiben sie sich gegenseitig!

${c.green}Loesung:${c.reset} Jedes Facet bekommt seinen eigenen "Namespace":

${c.dim}// Facet A Storage${c.reset}
${c.green}bytes32 constant STORAGE_A = keccak256("facet.a.storage");

struct StorageA {
    uint256 value;
    mapping(address => uint) balances;
}

function getStorageA() internal pure returns (StorageA storage s) {
    bytes32 position = STORAGE_A;
    assembly { s.slot := position }
}${c.reset}

${c.yellow}Jedes Facet hat so seinen eigenen, kollisionsfreien Speicherbereich!${c.reset}
`
  },
  {
    title: "DiamondCut - Der Juwelier",
    icon: `${c.red}><${c.reset}`,
    content: `
${c.bold}DiamondCut${c.reset} ist DIE zentrale Funktion zum Upgraden.

Drei Aktionen moeglich:
  ${c.green}Add${c.reset}     - Neue Funktionen hinzufuegen
  ${c.yellow}Replace${c.reset} - Bestehende Funktionen ersetzen
  ${c.red}Remove${c.reset}  - Funktionen entfernen

${c.dim}struct FacetCut {
    address facetAddress;
    FacetCutAction action;    // Add, Replace, Remove
    bytes4[] functionSelectors;
}

function diamondCut(
    FacetCut[] calldata _diamondCut,
    address _init,
    bytes calldata _calldata
) external;${c.reset}

${c.yellow}Fun Fact:${c.reset} Der Name "Cut" kommt vom Diamantenschleifen.
Genau wie ein Juwelier einen Rohdiamanten in Form bringt,
formt ${c.bold}diamondCut${c.reset} deinen Smart Contract!
`
  },
];

// --- Quiz Fragen ---
const QUIZ = [
  {
    q: "Was ist die maximale Groesse eines einzelnen Smart Contracts auf Ethereum?",
    options: ["A) 12 KB", "B) 24.576 KB", "C) 48 KB", "D) Unbegrenzt"],
    correct: 1,
    explanation: "Richtig! Das Spurious Dragon Update (EIP-170) begrenzt Contracts auf 24.576 Bytes. Der Diamond Standard loest dieses Problem!"
  },
  {
    q: "Welcher EVM-Opcode ermoeglicht es dem Diamond, Code aus Facets auszufuehren?",
    options: ["A) call", "B) staticcall", "C) delegatecall", "D) create2"],
    correct: 2,
    explanation: "Genau! delegatecall fuehrt den Code eines anderen Contracts im eigenen Kontext aus. Der Storage bleibt beim Diamond!"
  },
  {
    q: "Was ist die 'Loupe' im Diamond Standard?",
    options: ["A) Ein Debugging-Tool", "B) Eine Juwelierslupe zum Inspizieren der Facets", "C) Ein Gas-Optimierer", "D) Ein Storage-Manager"],
    correct: 1,
    explanation: "Korrekt! DiamondLoupe (frz. 'Lupe') laesst dich inspizieren, welche Facets und Funktionen ein Diamond hat. Sehr meta!"
  },
  {
    q: "Warum braucht man das Diamond Storage Pattern?",
    options: ["A) Fuer bessere Performance", "B) Weil Solidity es verlangt", "C) Um Storage-Kollisionen zwischen Facets zu vermeiden", "D) Fuer niedrigere Gas-Kosten"],
    correct: 2,
    explanation: "Richtig! Ohne Diamond Storage wuerden verschiedene Facets sich gegenseitig die Storage-Slots ueberschreiben. Chaos!"
  },
  {
    q: "Was passiert bei einem 'diamondCut' Aufruf?",
    options: ["A) Der Diamond wird zerstoert", "B) Facets werden hinzugefuegt, ersetzt oder entfernt", "C) Gas wird zurueckerstattet", "D) Der Contract wird pausiert"],
    correct: 1,
    explanation: "Genau! diamondCut ist die Upgrade-Funktion. Damit kannst du Facets hinzufuegen, ersetzen oder entfernen - wie ein Juwelier!"
  },
];

// --- Hilfsfunktionen ---
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function randomJoke() {
  return DIAMOND_JOKES[Math.floor(Math.random() * DIAMOND_JOKES.length)];
}

function printSeparator() {
  console.log(`${c.dim}${'─'.repeat(60)}${c.reset}`);
}

function printBoxed(text, color = c.cyan) {
  const lines = text.split('\n');
  const maxLen = Math.max(...lines.map(l => l.replace(/\x1b\[\d+m/g, '').length));
  const border = '═'.repeat(maxLen + 2);
  console.log(`${color}╔${border}╗${c.reset}`);
  lines.forEach(line => {
    const plainLen = line.replace(/\x1b\[\d+m/g, '').length;
    const padding = ' '.repeat(maxLen - plainLen);
    console.log(`${color}║${c.reset} ${line}${padding} ${color}║${c.reset}`);
  });
  console.log(`${color}╚${border}╝${c.reset}`);
}

async function typeWriter(text, delay = 15) {
  for (const char of text) {
    process.stdout.write(char);
    await sleep(delay);
  }
  console.log();
}

async function animateDiamond() {
  const frames = [
    `${c.cyan}    ${c.reset}`,
    `${c.cyan}  .${c.reset} `,
    `${c.cyan} /\\${c.reset} `,
    `${c.cyan}/  \\${c.reset}`,
    `${c.cyan}\\  /${c.reset}`,
    `${c.cyan} \\/${c.reset} `,
  ];
  for (let i = 0; i < 3; i++) {
    for (const frame of frames) {
      process.stdout.write(`\r  ${frame}  `);
      await sleep(80);
    }
  }
  process.stdout.write('\r       \r');
}

// --- Hauptmenue ---
async function showMainMenu(rl) {
  console.log(DIAMOND_BIG);

  await typeWriter(
    `${c.bold}${c.yellow}Willkommen zum Diamond Standard Tutorial!${c.reset}`,
    30
  );
  console.log();
  await typeWriter(
    `${c.dim}EIP-2535 verstehen - mit Spass im Terminal.${c.reset}`,
    20
  );
  console.log();

  printBoxed(
    `${c.bold}${c.yellow}Tipp des Tages:${c.reset}\n${randomJoke()}`
  );

  console.log();

  while (true) {
    console.log(`${c.bold}${c.cyan}Was moechtest du tun?${c.reset}`);
    console.log();
    console.log(`  ${c.yellow}[1]${c.reset} ${SPARKLE} Lektionen durchgehen`);
    console.log(`  ${c.yellow}[2]${c.reset} ${SPARKLE} Quiz starten`);
    console.log(`  ${c.yellow}[3]${c.reset} ${SPARKLE} Diamond-Witz hoeren`);
    console.log(`  ${c.yellow}[4]${c.reset} ${SPARKLE} Diamond ASCII Art Show`);
    console.log(`  ${c.yellow}[5]${c.reset} ${SPARKLE} Schnell-Referenz (Cheatsheet)`);
    console.log(`  ${c.yellow}[q]${c.reset}    Beenden`);
    console.log();

    const choice = await askQuestion(rl, `${c.cyan}Deine Wahl > ${c.reset}`);

    switch (choice.trim()) {
      case '1':
        await showLessons(rl);
        break;
      case '2':
        await runQuiz(rl);
        break;
      case '3':
        console.log();
        await animateDiamond();
        printBoxed(randomJoke(), c.magenta);
        console.log();
        break;
      case '4':
        await asciiArtShow();
        break;
      case '5':
        showCheatsheet();
        break;
      case 'q':
      case 'Q':
      case 'quit':
      case 'exit':
        console.log();
        await typeWriter(`${c.cyan}${c.bold}Bis zum naechsten Mal! Keep building diamonds! ${c.yellow}/\\${c.cyan} ${c.reset}`, 25);
        console.log();
        return;
      default:
        console.log(`${c.red}Unbekannte Eingabe. Bitte 1-5 oder 'q' waehlen.${c.reset}\n`);
    }
  }
}

// --- Lektionen ---
async function showLessons(rl) {
  for (let i = 0; i < LESSONS.length; i++) {
    const lesson = LESSONS[i];
    console.log();
    printSeparator();
    console.log(`${c.bold}${c.yellow}  Lektion ${i + 1}/${LESSONS.length}: ${lesson.icon} ${lesson.title}${c.reset}`);
    printSeparator();
    console.log(lesson.content);

    if (i < LESSONS.length - 1) {
      const ans = await askQuestion(rl, `${c.cyan}[Enter] Naechste Lektion | [q] Zurueck zum Menue > ${c.reset}`);
      if (ans.trim().toLowerCase() === 'q') return;
    } else {
      console.log(`${c.green}${c.bold}Alle Lektionen abgeschlossen! Du bist jetzt ein Diamond-Experte!${c.reset}`);
      console.log();
      await askQuestion(rl, `${c.cyan}[Enter] Zurueck zum Menue > ${c.reset}`);
    }
  }
}

// --- Quiz ---
async function runQuiz(rl) {
  console.log();
  printBoxed(`${c.bold}${c.yellow}Diamond Standard Quiz${c.reset}\n${c.dim}5 Fragen - Teste dein Wissen!${c.reset}`);
  console.log();

  let score = 0;

  for (let i = 0; i < QUIZ.length; i++) {
    const q = QUIZ[i];
    console.log(`${c.bold}${c.yellow}Frage ${i + 1}/${QUIZ.length}:${c.reset}`);
    console.log(`${c.bold}${q.q}${c.reset}`);
    console.log();
    q.options.forEach((opt, idx) => {
      console.log(`  ${c.cyan}${opt}${c.reset}`);
    });
    console.log();

    const answer = await askQuestion(rl, `${c.yellow}Deine Antwort (A/B/C/D) > ${c.reset}`);
    const ansIdx = 'abcd'.indexOf(answer.trim().toLowerCase());

    if (ansIdx === q.correct) {
      score++;
      console.log(`\n${c.green}${c.bold}Richtig!${c.reset} ${SPARKLE}${SPARKLE}${SPARKLE}`);
    } else {
      const correctLetter = 'ABCD'[q.correct];
      console.log(`\n${c.red}Leider falsch!${c.reset} Die richtige Antwort war ${c.green}${correctLetter}${c.reset}.`);
    }
    console.log(`${c.dim}${q.explanation}${c.reset}`);
    console.log();
    printSeparator();
    console.log();
  }

  // Ergebnis
  const percentage = (score / QUIZ.length) * 100;
  console.log();
  if (percentage === 100) {
    printBoxed(
      `${c.bold}${c.yellow}PERFEKT! ${score}/${QUIZ.length} (${percentage}%)${c.reset}\n` +
      `Du bist ein wahrer Diamond-Meister!\n` +
      `Dein Wissen glaenzt heller als jeder Diamant!`,
      c.yellow
    );
  } else if (percentage >= 60) {
    printBoxed(
      `${c.bold}${c.green}Gut gemacht! ${score}/${QUIZ.length} (${percentage}%)${c.reset}\n` +
      `Solides Wissen! Noch ein paar Facets zu polieren.`,
      c.green
    );
  } else {
    printBoxed(
      `${c.bold}${c.red}${score}/${QUIZ.length} (${percentage}%)${c.reset}\n` +
      `Noch ein Rohdiamant! Geh die Lektionen nochmal durch.`,
      c.red
    );
  }
  console.log();
  await askQuestion(rl, `${c.cyan}[Enter] Zurueck zum Menue > ${c.reset}`);
}

// --- ASCII Art Show ---
async function asciiArtShow() {
  console.log();
  console.log(`${c.bold}${c.magenta}  ~ Diamond Art Gallery ~${c.reset}`);
  console.log();

  // Animated sparkle line
  const width = 50;
  for (let i = 0; i < width; i++) {
    const line = Array(width).fill(' ').map((_, j) => {
      if (j === i || j === width - 1 - i) return `${c.yellow}*${c.reset}`;
      if (j === Math.floor(width / 2)) return `${c.cyan}|${c.reset}`;
      return ' ';
    }).join('');
    process.stdout.write(`\r${line}`);
    await sleep(30);
  }
  console.log();

  // Diamond rain
  console.log(`\n${c.bold}${c.cyan}  Diamond Rain:${c.reset}\n`);
  for (let row = 0; row < 8; row++) {
    let line = '  ';
    for (let col = 0; col < 15; col++) {
      const r = Math.random();
      if (r < 0.15) line += `${c.cyan}/\\${c.reset}`;
      else if (r < 0.25) line += `${c.yellow}*${c.reset} `;
      else if (r < 0.35) line += `${c.magenta}<>${c.reset}`;
      else line += '  ';
    }
    console.log(line);
    await sleep(150);
  }

  // Big rotating diamond effect
  console.log(`\n${c.bold}${c.yellow}  Der Diamant in all seiner Pracht:${c.reset}`);
  console.log(DIAMOND_BIG);
  console.log(FACET_ART);
}

// --- Cheatsheet ---
function showCheatsheet() {
  console.log();
  console.log(`
${c.bold}${c.cyan}╔══════════════════════════════════════════════════════╗
║         DIAMOND STANDARD SCHNELL-REFERENZ            ║
╠══════════════════════════════════════════════════════╣${c.reset}
${c.bold}│ Konzept          │ Beschreibung                     │${c.reset}
${c.dim}├──────────────────┼──────────────────────────────────┤${c.reset}
│ ${c.cyan}Diamond${c.reset}          │ Proxy Contract (Haupteingang)    │
│ ${c.magenta}Facet${c.reset}            │ Implementierungs-Contract        │
│ ${c.yellow}DiamondCut${c.reset}       │ Upgrade-Funktion (Add/Replace/   │
│                  │ Remove Facets)                    │
│ ${c.green}DiamondLoupe${c.reset}     │ Inspektion (welche Facets/Fns?)  │
│ ${c.blue}Diamond Storage${c.reset}  │ Namespaced Storage per Facet     │
│ ${c.red}fallback()${c.reset}       │ Leitet Calls an richtige Facet   │
│ ${c.green}delegatecall${c.reset}     │ Fuehrt Facet-Code im Diamond-    │
│                  │ Kontext aus                       │
${c.dim}├──────────────────┼──────────────────────────────────┤${c.reset}
${c.bold}│ Interfaces       │                                  │${c.reset}
${c.dim}├──────────────────┼──────────────────────────────────┤${c.reset}
│ ${c.cyan}IDiamondCut${c.reset}      │ diamondCut() Funktion            │
│ ${c.cyan}IDiamondLoupe${c.reset}    │ facets(), facetAddresses(),       │
│                  │ facetAddress(), facetFnSelectors()│
│ ${c.cyan}IERC165${c.reset}          │ supportsInterface()              │
${c.dim}└──────────────────┴──────────────────────────────────┘${c.reset}

${c.yellow}${c.bold}EIP:${c.reset} ${c.dim}https://eips.ethereum.org/EIPS/eip-2535${c.reset}
${c.yellow}${c.bold}Referenz:${c.reset} ${c.dim}https://github.com/mudgen/diamond-3${c.reset}
`);
}

// --- Input Helper ---
function askQuestion(rl, prompt) {
  return new Promise(resolve => {
    rl.question(prompt, answer => {
      resolve(answer);
    });
  });
}

// --- CLI Argument Handling ---
async function main() {
  const args = process.argv.slice(2);

  // Quick modes
  if (args.includes('--joke') || args.includes('-j')) {
    console.log();
    console.log(`${c.yellow}${c.bold}Diamond-Witz:${c.reset}`);
    console.log(`${c.cyan}${randomJoke()}${c.reset}`);
    console.log();
    process.exit(0);
  }

  if (args.includes('--test')) {
    console.log(`${c.green}${c.bold}Diamond Standard Tutorial CLI - Test OK!${c.reset}`);
    console.log(`${c.dim}Version 1.0.0 | Node ${process.version}${c.reset}`);
    console.log(`${c.dim}Lektionen: ${LESSONS.length} | Quiz-Fragen: ${QUIZ.length} | Witze: ${DIAMOND_JOKES.length}${c.reset}`);
    process.exit(0);
  }

  // Interactive mode
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  try {
    if (args.includes('--quiz') || args.includes('-q')) {
      await runQuiz(rl);
    } else {
      await showMainMenu(rl);
    }
  } finally {
    rl.close();
  }
}

main().catch(err => {
  console.error(`${c.red}Fehler: ${err.message}${c.reset}`);
  process.exit(1);
});
