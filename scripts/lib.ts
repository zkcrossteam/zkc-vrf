import BN from 'bn.js';
export class U8ArrayUtil {
    u8arr: Uint8Array;
    constructor(data: Uint8Array) {
        this.u8arr = data;
    }
    toBN() {
        let bns = new Array<BN>();
        for (let i = 0; i < this.u8arr.length; i += 32) {
            const chunk = this.u8arr.slice(i, i + 32);
            let a = new BN(chunk, 'le');
            bns.push(a);
        }
        return bns;
    }
    toNumber() {
        return this.toBN().map((x) => x.toString(10));
    }
}

export class AddressUtil {
    address: Address;
    constructor(address: string) {
        this.address = new Address(address);
    }
    toBN(){
        let addr256 = this.address.toU256Bytes();
        let bns = new Array<BN>();
        for (let i = 0; i < addr256.length; i += 16) {
            const chunk = addr256.slice(i, i + 16);
            let a = new BN(chunk, 'hex', 'be');
            bns.push(a);
        }
        return bns;
    }
    toNumber() {
        return this.toBN().map((x) => x.toString(10));
    }
}

export class NumberUtil {
    bn: BN;
    constructor(num: number) {
        this.bn = new BN(num);
    }
    toBN(){
        let bns = new Array<BN>();
        let bnStr = this.bn.toString("hex", 64)
        for (let i = 0; i < bnStr.length; i += 16) {
            const chunk = bnStr.slice(i, i + 16);
            let a = new BN(chunk, 'hex', 'be');
            bns.push(a);
        }
        return bns;
    }
    toNumber() {
        return this.toBN().map((x) => x.toString(10));
    }
}
