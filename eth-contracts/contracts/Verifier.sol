// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity ^0.5.2;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.A = Pairing.G2Point([0x23dc48eb12044629b7200bf47c2b68df3cf31b8a43b19a1551138c07da7fb411, 0x149ef91ffc9d875677f5e73aec1b0db1030f2308b4b02e55110152390c247629], [0x741386accc75273f67a94631722652345383dc6fd5f62ab94fc0716f8d06c6f, 0x2218d812616158c7ff62309fc10daaddd93c2ade948fec1d7380803530945210]);
        vk.B = Pairing.G1Point(0x302e0b5a42101bb56bbc9ef0f470d09bdd649daf0a7dc98b341793e309d0b3d1, 0x2c6ca8c9d976572f93710180253955ef332565bf68f208b82d0d246fbaf17141);
        vk.C = Pairing.G2Point([0x1b261a58ff837b3683336c5b44ee5838f35b5bff43f60c1eaff88c50175d9232, 0x162ce9d256c3014dbe863af2a7ce02dd3aeaaa57bcb46023f86fbf66ec0ba60b], [0xeecc1acf6681e086c8622674f5b66cf24ed4dbea2cbf41d224e388bb2c1c0c7, 0x13d9f51537476244e08dd98286a6e23d9fe0e1e8ece4356856809e25db196cff]);
        vk.gamma = Pairing.G2Point([0x2473f2c24bd0fe6e4ec81f2d5c96f6e90d2b763dff76f12b4dfe2b4ca8f1cf00, 0x102404f1000bd1d41799814d819b610b45ab00262fb58fce94cbdcf7fa49f2], [0xc7b5d237f726eca7b7f8b2c3ad599fcd8a524b12080102ae4dd13ba6d07e6e5, 0x6a6b1f0e1ed69f7102eed2e63b54acd1844b09d4869e6620e340df12b93d3a3]);
        vk.gammaBeta1 = Pairing.G1Point(0x1774fdcab92d593bda638bada160610e08b92b958ad5b57127b9bafc4b64bf52, 0xdd7fdda52d85bc8ccb1c512501661d95255e9bd346dcf07396082f03498e4de);
        vk.gammaBeta2 = Pairing.G2Point([0x2240dc62b0e46b5c08645020c93a69f0cf35a9083a3f76a1580a8d40cba1682e, 0x11e9b6a4156f63aea7100ebf2b1879d419aeab6eeae63fce81bd7713b22ba987], [0x94328be34e93b1f0b4404c191a2d7c790795b0f109b8676ae47d9bf9e83b59e, 0x215eda9ed4cbc1cea1aee46c1cf7b65b724c14b736e0f70986cf8b0ada4e102b]);
        vk.Z = Pairing.G2Point([0x18deec112ad310ce4894b9485be62cf77433267359db8002c5b7840efc54beee, 0x1938087bff8e25c4d9e897671a067c196ea3772a081fb8c92321a096c7999545], [0x1b5bf164d5d4381179c34a1ffaf18fa0023cdec01bed19cba994edd1555f074b, 0xc11acac6947b01120c16632506b5cae3a4926cfab8c878ca48f6a007af53b93]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0x1c801d5d92c7fb2289bacd7837959a82a7482bb05f8ac9a9c31546784f5d25d1, 0x1bf15abfa3a6153855c4b85eaac51b25ae095581982aed0bfe01c8a76216d82b);
        vk.IC[1] = Pairing.G1Point(0x1620361d57a3f71fa86a7b398c1e2610707cd5e33ab02bd2f4aaa122a20c6866, 0x1cdafae2ee96515ceaf1c71cba4fc540edc6c97b52266dbe16482aefb3d51cbf);
        vk.IC[2] = Pairing.G1Point(0x2741de58be4c6f18d8e4769ceb2cced5739a5018ee5a0eb61dd6d7150a89a712, 0x2f6dc18067c5d2c119906af7cd85f78c3b0c2ad4309240486ed16d64e0c1dbbd);
    }
    function verify(uint[] memory input, Proof memory proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string s);
    function verifyTx(
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[2] memory input
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
