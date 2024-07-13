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
let rlc = document.getElementById('rlc');

//input.setAttribute('onchange', 'premin()') // Add here to avoid DOM loading issues
input.addEventListener('change', premin)

minifyBtn.addEventListener('click', minify);

let rules = document.querySelectorAll('input:not(#debug)'); // https://stackoverflow.com/a/40956816
rules.forEach(function(rule) {
    rule.addEventListener('click', premin);
});

function premin() {
    if (!live.checked) return;
    minify();
}

function minify() {
    minification = input.value;
    minification = commentStripper(minification);
    //minification = shortVariables(minification);
    minification = removeWhitespaces(minification);
    minification = removeIndents(minification);
    minification = removeBlankMsgBox(minification);
    minification = removeAllMsgBox(minification);
    minification = optimiseOptions(minification);
    minification = useOtb(minification);
    minification = useShorthand(minification);
    minification = removeEmptyLines(minification);
    minification = removeTrailingSpaces(minification);
    //minification = reduceLineCount(minification);
    output.value = minification; // Output to second textarea
};

function commentStripper(minification) {
    if (!cs.checked) return minification;
    let min = minification.replace(/\B;.*/g, '');
    min = min.replace(/^\s*\/\*((\S\*\/\S)|.)*?\*\//gms, ''); // TODO: Still fails https://regex101.com/r/KTXStY/1
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
    min = min.replace(/\s+([~><=!:\+\-\*\/\.&|^]+==?|=)\s+/g, '$1');
    min = min.replace(/^(\s*)(if|while)\s*?\(/gmi, '$1$2(')
    min = min.replace(/^([^"']*\()\s*/gm, '$1') // WIP Rule: Only removes whitespace before first param in funcs
    return min;
};

function removeIndents(minification) {
    if (!ri.checked) return minification;
    let min = minification.replace(/^\s+/gm, '');
    return min;
};

function removeBlankMsgBox(minification) {
    if (!rbm.checked) return minification;
    let min = minification.replace(/^\s*MsgBox(\(\))?$/gmi, '');
    return min;
};

function removeAllMsgBox(minification) {
    if (!ram.checked) return minification;
    let min = minification.replace(/^\s*MsgBox(\(.*\))?( ['"].*['"])?$/gmi, '');
    return min;
};

function optimiseOptions(minification) {
    if (!oo.checked) return minification;
    //console.log(minification.replace(/(?<=MsgBox.*,\s*)(0x\d+)(?=\)|$)/gmi, '$1'))
    //let min = minification.replace(/(MsgBox.*,\s*)(0x\d+)(\)|$)/gmi, '$1' + parseInt(minification.replace(/(?<=MsgBox.*,\s*)(0x\d+)(?=\)|$)/gmi, '$1')) + '$3');
    let min = minification.replace(/((^| )Click( |\().*)Relative(.*$)/gmi, '$1Rel$4')
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
    min = min.replace(/(\s*if|while|for|loop(\s*|\().*?){\n(.*)\n}/gmi, '$1\n$2');
    min = min.replace(/(\s*.*)\.Add\("(ActiveX|Button|CheckBox|ComboBox|Custom|DateTime|DropDownList|DDL|Edit|GroupBox|Hotkey|Link|ListBox|ListView|MonthCal|Picture|Pic|Progress|Radio|Slider|StatusBar|Tab|Tab2|Tab3|Text|TreeView|UpDown)",/gmi, '$1.Add$2(')
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

function reduceLineCount(minification) { // Will try and reduce the amount of lines
    if (!rlc.checked) return minification;
    let min = minification.replace(/temp/g, '');
    return min;
}