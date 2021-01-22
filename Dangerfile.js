// import custom DangerJS rules
// see http://danger.systems/js
// see https://github.com/teamdigitale/danger-plugin-digitalcitizenship/
// tslint:disable-next-line:prettier
const { default: checkDangers } = require("danger-plugin-digitalcitizenship");

checkDangers();
