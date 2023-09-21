let input = document.getElementById('input');
let output = document.getElementById('output');
let minifyBtn = document.getElementById('minify');
let live = document.getElementById('live');

let cs = document.getElementById('cs');
let sv = document.getElementById('sv');
let rw = document.getElementById('rw');
let ri = document.getElementById('ri');
let rbm = document.getElementById('rbm');
let ram = document.getElementById('ram');
let oo = document.getElementById('oo');
let uo = document.getElementById('uo');
let us = document.getElementById('us');
let rel = document.getElementById('rel');
let rts = document.getElementById('rts');

input.addEventListener('keyup', premin);
input.addEventListener('cut', premin); // Doesn't detect RMB -> Cut until second use, same with paste (atleast on FF)
input.addEventListener('paste', premin);
minifyBtn.addEventListener('click', minify);

cs.addEventListener('click', premin);
sv.addEventListener('click', premin);
rw.addEventListener('click', premin);
ri.addEventListener('click', premin);
rbm.addEventListener('click', premin);
ram.addEventListener('click', premin);
oo.addEventListener('click', premin);
uo.addEventListener('click', premin);
us.addEventListener('click', premin);
rel.addEventListener('click', premin);
rts.addEventListener('click', premin);

live.addEventListener('click', premin);

function premin() {
    if (!live.checked) return
    minify()
}

function minify() {
    minification = input.value;
    minification = commentStripper(minification);
    //minification = shortVariables(minification);
    minification = removeWhitespaces(minification);
    minification = removeIndents(minification);
    minification = removeBlankMsgBox(minification);
    minification = removeAllMsgBox(minification);
    //minification = optimiseOptions(minification);
    minification = useOtb(minification);
    minification = useShorthand(minification);
    minification = removeEmptyLines(minification);
    minification = removeTrailingSpaces(minification);
    output.value = minification; // Output to second textarea
};

function commentStripper(minification) {
    if (!cs.checked) return minification;
    let min = minification.replace(/\B;.*/gm, '');
    min = min.replace(/^\s*\/\*.*?\*\//gms, '');
    return min;
};

function shortVariables(minification) {
    if (!sv.checked) return minification;
    let min = minification.replace(/temp/g, '');
    return min;
};

function removeWhitespaces(minification) {
    if (!rw.checked) return minification;
    let min = minification.replace(/\)\s+{/g, '){');
    min = min.replace(/\s+(?=[~><=!:\+\-\*\/\.&|^]+==?|=)|(?<=[~><=!:\+\-\*\/\.&|^])\s+/g, '');
    return min;
};

function removeIndents(minification) {
    if (!ri.checked) return minification;
    let min = minification.replace(/^\s+/gm, '');
    return min;
};

function removeBlankMsgBox(minification) {
    if (!rbm.checked) return minification;
    let min = minification.replace(/^\s*MsgBox(\(\))?$/gm, '');
    return min;
};

function removeAllMsgBox(minification) {
    if (!ram.checked) return minification;
    let min = minification.replace(/^\s*MsgBox(\(.*\))?( ['"].*['"])?$/gm, '');
    return min;
};

function optimiseOptions(minification) {
    if (!oo.checked) return minification;
    let min = minification.replace(/temp/g, '');
    return min;
};

function useOtb(minification) {
    if (!uo.checked) return minification;
    let min = minification.replace(/\n{/g, '{');
    return min;
};

function useShorthand(minification) {
    if (!us.checked) return minification;
    let min = minification.replace(/\s*\+=\s*1$/gm, '++');
    min = min.replace(/\s*-=\s*1$/gm, '--');
    return min;
};

function removeEmptyLines(minification) {
    if (!rel.checked) return minification;
    let min = minification.replace(/^\s*\n/gm, '');
    return min;
};

function removeTrailingSpaces(minification) {
    if (!rts.checked) return minification;
    let min = minification.replace(/\s+$/g, '');
    return min;
};