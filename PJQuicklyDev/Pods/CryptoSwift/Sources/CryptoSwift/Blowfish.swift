//
//  CryptoSwift
//
//  Copyright (C) 2014-2017 Marcin Krzyżanowski <marcin@krzyzanowskim.com>
//  This software is provided 'as-is', without any express or implied warranty.
//
//  In no event will the authors be held liable for any damages arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
//  - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
//  - This notice may not be removed or altered from any source or binary distribution.
//

//  https://en.wikipedia.org/wiki/Blowfish_(cipher)
//  Based on Paul Kocher implementation
//

public final class Blowfish {
    public enum Error: Swift.Error {
        /// Data padding is required
        case dataPaddingRequired
        /// Invalid key or IV
        case invalidKeyOrInitializationVector
        /// Invalid IV
        case invalidInitializationVector
        /// Invalid block mode
        case invalidBlockMode
    }

    public static let blockSize: Int = 8 // 64 bit
    public let keySize: Int

    private let blockMode: BlockMode
    private let padding: Padding
    private var decryptWorker: CipherModeWorker!
    private var encryptWorker: CipherModeWorker!

    private let N = 16 // rounds
    private var P: [UInt32]
    private var S: [[UInt32]]
    private let origP: [UInt32] = [
        0x243F_6A88, 0x85A3_08D3, 0x1319_8A2E, 0x0370_7344, 0xA409_3822,
        0x299F_31D0, 0x082E_FA98, 0xEC4E_6C89, 0x4528_21E6, 0x38D0_1377,
        0xBE54_66CF, 0x34E9_0C6C, 0xC0AC_29B7, 0xC97C_50DD, 0x3F84_D5B5,
        0xB547_0917, 0x9216_D5D9, 0x8979_FB1B,
    ]

    private let origS: [[UInt32]] = [
        [
            0xD131_0BA6, 0x98DF_B5AC, 0x2FFD_72DB, 0xD01A_DFB7,
            0xB8E1_AFED, 0x6A26_7E96, 0xBA7C_9045, 0xF12C_7F99,
            0x24A1_9947, 0xB391_6CF7, 0x0801_F2E2, 0x858E_FC16,
            0x6369_20D8, 0x7157_4E69, 0xA458_FEA3, 0xF493_3D7E,
            0x0D95_748F, 0x728E_B658, 0x718B_CD58, 0x8215_4AEE,
            0x7B54_A41D, 0xC25A_59B5, 0x9C30_D539, 0x2AF2_6013,
            0xC5D1_B023, 0x2860_85F0, 0xCA41_7918, 0xB8DB_38EF,
            0x8E79_DCB0, 0x603A_180E, 0x6C9E_0E8B, 0xB01E_8A3E,
            0xD715_77C1, 0xBD31_4B27, 0x78AF_2FDA, 0x5560_5C60,
            0xE655_25F3, 0xAA55_AB94, 0x5748_9862, 0x63E8_1440,
            0x55CA_396A, 0x2AAB_10B6, 0xB4CC_5C34, 0x1141_E8CE,
            0xA154_86AF, 0x7C72_E993, 0xB3EE_1411, 0x636F_BC2A,
            0x2BA9_C55D, 0x7418_31F6, 0xCE5C_3E16, 0x9B87_931E,
            0xAFD6_BA33, 0x6C24_CF5C, 0x7A32_5381, 0x2895_8677,
            0x3B8F_4898, 0x6B4B_B9AF, 0xC4BF_E81B, 0x6628_2193,
            0x61D8_09CC, 0xFB21_A991, 0x487C_AC60, 0x5DEC_8032,
            0xEF84_5D5D, 0xE985_75B1, 0xDC26_2302, 0xEB65_1B88,
            0x2389_3E81, 0xD396_ACC5, 0x0F6D_6FF3, 0x83F4_4239,
            0x2E0B_4482, 0xA484_2004, 0x69C8_F04A, 0x9E1F_9B5E,
            0x21C6_6842, 0xF6E9_6C9A, 0x670C_9C61, 0xABD3_88F0,
            0x6A51_A0D2, 0xD854_2F68, 0x960F_A728, 0xAB51_33A3,
            0x6EEF_0B6C, 0x137A_3BE4, 0xBA3B_F050, 0x7EFB_2A98,
            0xA1F1_651D, 0x39AF_0176, 0x66CA_593E, 0x8243_0E88,
            0x8CEE_8619, 0x456F_9FB4, 0x7D84_A5C3, 0x3B8B_5EBE,
            0xE06F_75D8, 0x85C1_2073, 0x401A_449F, 0x56C1_6AA6,
            0x4ED3_AA62, 0x363F_7706, 0x1BFE_DF72, 0x429B_023D,
            0x37D0_D724, 0xD00A_1248, 0xDB0F_EAD3, 0x49F1_C09B,
            0x0753_72C9, 0x8099_1B7B, 0x25D4_79D8, 0xF6E8_DEF7,
            0xE3FE_501A, 0xB679_4C3B, 0x976C_E0BD, 0x04C0_06BA,
            0xC1A9_4FB6, 0x409F_60C4, 0x5E5C_9EC2, 0x196A_2463,
            0x68FB_6FAF, 0x3E6C_53B5, 0x1339_B2EB, 0x3B52_EC6F,
            0x6DFC_511F, 0x9B30_952C, 0xCC81_4544, 0xAF5E_BD09,
            0xBEE3_D004, 0xDE33_4AFD, 0x660F_2807, 0x192E_4BB3,
            0xC0CB_A857, 0x45C8_740F, 0xD20B_5F39, 0xB9D3_FBDB,
            0x5579_C0BD, 0x1A60_320A, 0xD6A1_00C6, 0x402C_7279,
            0x679F_25FE, 0xFB1F_A3CC, 0x8EA5_E9F8, 0xDB32_22F8,
            0x3C75_16DF, 0xFD61_6B15, 0x2F50_1EC8, 0xAD05_52AB,
            0x323D_B5FA, 0xFD23_8760, 0x5331_7B48, 0x3E00_DF82,
            0x9E5C_57BB, 0xCA6F_8CA0, 0x1A87_562E, 0xDF17_69DB,
            0xD542_A8F6, 0x287E_FFC3, 0xAC67_32C6, 0x8C4F_5573,
            0x695B_27B0, 0xBBCA_58C8, 0xE1FF_A35D, 0xB8F0_11A0,
            0x10FA_3D98, 0xFD21_83B8, 0x4AFC_B56C, 0x2DD1_D35B,
            0x9A53_E479, 0xB6F8_4565, 0xD28E_49BC, 0x4BFB_9790,
            0xE1DD_F2DA, 0xA4CB_7E33, 0x62FB_1341, 0xCEE4_C6E8,
            0xEF20_CADA, 0x3677_4C01, 0xD07E_9EFE, 0x2BF1_1FB4,
            0x95DB_DA4D, 0xAE90_9198, 0xEAAD_8E71, 0x6B93_D5A0,
            0xD08E_D1D0, 0xAFC7_25E0, 0x8E3C_5B2F, 0x8E75_94B7,
            0x8FF6_E2FB, 0xF212_2B64, 0x8888_B812, 0x900D_F01C,
            0x4FAD_5EA0, 0x688F_C31C, 0xD1CF_F191, 0xB3A8_C1AD,
            0x2F2F_2218, 0xBE0E_1777, 0xEA75_2DFE, 0x8B02_1FA1,
            0xE5A0_CC0F, 0xB56F_74E8, 0x18AC_F3D6, 0xCE89_E299,
            0xB4A8_4FE0, 0xFD13_E0B7, 0x7CC4_3B81, 0xD2AD_A8D9,
            0x165F_A266, 0x8095_7705, 0x93CC_7314, 0x211A_1477,
            0xE6AD_2065, 0x77B5_FA86, 0xC754_42F5, 0xFB9D_35CF,
            0xEBCD_AF0C, 0x7B3E_89A0, 0xD641_1BD3, 0xAE1E_7E49,
            0x0025_0E2D, 0x2071_B35E, 0x2268_00BB, 0x57B8_E0AF,
            0x2464_369B, 0xF009_B91E, 0x5563_911D, 0x59DF_A6AA,
            0x78C1_4389, 0xD95A_537F, 0x207D_5BA2, 0x02E5_B9C5,
            0x8326_0376, 0x6295_CFA9, 0x11C8_1968, 0x4E73_4A41,
            0xB347_2DCA, 0x7B14_A94A, 0x1B51_0052, 0x9A53_2915,
            0xD60F_573F, 0xBC9B_C6E4, 0x2B60_A476, 0x81E6_7400,
            0x08BA_6FB5, 0x571B_E91F, 0xF296_EC6B, 0x2A0D_D915,
            0xB663_6521, 0xE7B9_F9B6, 0xFF34_052E, 0xC585_5664,
            0x53B0_2D5D, 0xA99F_8FA1, 0x08BA_4799, 0x6E85_076A,
        ],
        [
            0x4B7A_70E9, 0xB5B3_2944, 0xDB75_092E, 0xC419_2623,
            0xAD6E_A6B0, 0x49A7_DF7D, 0x9CEE_60B8, 0x8FED_B266,
            0xECAA_8C71, 0x699A_17FF, 0x5664_526C, 0xC2B1_9EE1,
            0x1936_02A5, 0x7509_4C29, 0xA059_1340, 0xE418_3A3E,
            0x3F54_989A, 0x5B42_9D65, 0x6B8F_E4D6, 0x99F7_3FD6,
            0xA1D2_9C07, 0xEFE8_30F5, 0x4D2D_38E6, 0xF025_5DC1,
            0x4CDD_2086, 0x8470_EB26, 0x6382_E9C6, 0x021E_CC5E,
            0x0968_6B3F, 0x3EBA_EFC9, 0x3C97_1814, 0x6B6A_70A1,
            0x687F_3584, 0x52A0_E286, 0xB79C_5305, 0xAA50_0737,
            0x3E07_841C, 0x7FDE_AE5C, 0x8E7D_44EC, 0x5716_F2B8,
            0xB03A_DA37, 0xF050_0C0D, 0xF01C_1F04, 0x0200_B3FF,
            0xAE0C_F51A, 0x3CB5_74B2, 0x2583_7A58, 0xDC09_21BD,
            0xD191_13F9, 0x7CA9_2FF6, 0x9432_4773, 0x22F5_4701,
            0x3AE5_E581, 0x37C2_DADC, 0xC8B5_7634, 0x9AF3_DDA7,
            0xA944_6146, 0x0FD0_030E, 0xECC8_C73E, 0xA475_1E41,
            0xE238_CD99, 0x3BEA_0E2F, 0x3280_BBA1, 0x183E_B331,
            0x4E54_8B38, 0x4F6D_B908, 0x6F42_0D03, 0xF60A_04BF,
            0x2CB8_1290, 0x2497_7C79, 0x5679_B072, 0xBCAF_89AF,
            0xDE9A_771F, 0xD993_0810, 0xB38B_AE12, 0xDCCF_3F2E,
            0x5512_721F, 0x2E6B_7124, 0x501A_DDE6, 0x9F84_CD87,
            0x7A58_4718, 0x7408_DA17, 0xBC9F_9ABC, 0xE94B_7D8C,
            0xEC7A_EC3A, 0xDB85_1DFA, 0x6309_4366, 0xC464_C3D2,
            0xEF1C_1847, 0x3215_D908, 0xDD43_3B37, 0x24C2_BA16,
            0x12A1_4D43, 0x2A65_C451, 0x5094_0002, 0x133A_E4DD,
            0x71DF_F89E, 0x1031_4E55, 0x81AC_77D6, 0x5F11_199B,
            0x0435_56F1, 0xD7A3_C76B, 0x3C11_183B, 0x5924_A509,
            0xF28F_E6ED, 0x97F1_FBFA, 0x9EBA_BF2C, 0x1E15_3C6E,
            0x86E3_4570, 0xEAE9_6FB1, 0x860E_5E0A, 0x5A3E_2AB3,
            0x771F_E71C, 0x4E3D_06FA, 0x2965_DCB9, 0x99E7_1D0F,
            0x803E_89D6, 0x5266_C825, 0x2E4C_C978, 0x9C10_B36A,
            0xC615_0EBA, 0x94E2_EA78, 0xA5FC_3C53, 0x1E0A_2DF4,
            0xF2F7_4EA7, 0x361D_2B3D, 0x1939_260F, 0x19C2_7960,
            0x5223_A708, 0xF713_12B6, 0xEBAD_FE6E, 0xEAC3_1F66,
            0xE3BC_4595, 0xA67B_C883, 0xB17F_37D1, 0x018C_FF28,
            0xC332_DDEF, 0xBE6C_5AA5, 0x6558_2185, 0x68AB_9802,
            0xEECE_A50F, 0xDB2F_953B, 0x2AEF_7DAD, 0x5B6E_2F84,
            0x1521_B628, 0x2907_6170, 0xECDD_4775, 0x619F_1510,
            0x13CC_A830, 0xEB61_BD96, 0x0334_FE1E, 0xAA03_63CF,
            0xB573_5C90, 0x4C70_A239, 0xD59E_9E0B, 0xCBAA_DE14,
            0xEECC_86BC, 0x6062_2CA7, 0x9CAB_5CAB, 0xB2F3_846E,
            0x648B_1EAF, 0x19BD_F0CA, 0xA023_69B9, 0x655A_BB50,
            0x4068_5A32, 0x3C2A_B4B3, 0x319E_E9D5, 0xC021_B8F7,
            0x9B54_0B19, 0x875F_A099, 0x95F7_997E, 0x623D_7DA8,
            0xF837_889A, 0x97E3_2D77, 0x11ED_935F, 0x1668_1281,
            0x0E35_8829, 0xC7E6_1FD6, 0x96DE_DFA1, 0x7858_BA99,
            0x57F5_84A5, 0x1B22_7263, 0x9B83_C3FF, 0x1AC2_4696,
            0xCDB3_0AEB, 0x532E_3054, 0x8FD9_48E4, 0x6DBC_3128,
            0x58EB_F2EF, 0x34C6_FFEA, 0xFE28_ED61, 0xEE7C_3C73,
            0x5D4A_14D9, 0xE864_B7E3, 0x4210_5D14, 0x203E_13E0,
            0x45EE_E2B6, 0xA3AA_ABEA, 0xDB6C_4F15, 0xFACB_4FD0,
            0xC742_F442, 0xEF6A_BBB5, 0x654F_3B1D, 0x41CD_2105,
            0xD81E_799E, 0x8685_4DC7, 0xE44B_476A, 0x3D81_6250,
            0xCF62_A1F2, 0x5B8D_2646, 0xFC88_83A0, 0xC1C7_B6A3,
            0x7F15_24C3, 0x69CB_7492, 0x4784_8A0B, 0x5692_B285,
            0x095B_BF00, 0xAD19_489D, 0x1462_B174, 0x2382_0E00,
            0x5842_8D2A, 0x0C55_F5EA, 0x1DAD_F43E, 0x233F_7061,
            0x3372_F092, 0x8D93_7E41, 0xD65F_ECF1, 0x6C22_3BDB,
            0x7CDE_3759, 0xCBEE_7460, 0x4085_F2A7, 0xCE77_326E,
            0xA607_8084, 0x19F8_509E, 0xE8EF_D855, 0x61D9_9735,
            0xA969_A7AA, 0xC50C_06C2, 0x5A04_ABFC, 0x800B_CADC,
            0x9E44_7A2E, 0xC345_3484, 0xFDD5_6705, 0x0E1E_9EC9,
            0xDB73_DBD3, 0x1055_88CD, 0x675F_DA79, 0xE367_4340,
            0xC5C4_3465, 0x713E_38D8, 0x3D28_F89E, 0xF16D_FF20,
            0x153E_21E7, 0x8FB0_3D4A, 0xE6E3_9F2B, 0xDB83_ADF7,
        ],
        [
            0xE93D_5A68, 0x9481_40F7, 0xF64C_261C, 0x9469_2934,
            0x4115_20F7, 0x7602_D4F7, 0xBCF4_6B2E, 0xD4A2_0068,
            0xD408_2471, 0x3320_F46A, 0x43B7_D4B7, 0x5000_61AF,
            0x1E39_F62E, 0x9724_4546, 0x1421_4F74, 0xBF8B_8840,
            0x4D95_FC1D, 0x96B5_91AF, 0x70F4_DDD3, 0x66A0_2F45,
            0xBFBC_09EC, 0x03BD_9785, 0x7FAC_6DD0, 0x31CB_8504,
            0x96EB_27B3, 0x55FD_3941, 0xDA25_47E6, 0xABCA_0A9A,
            0x2850_7825, 0x5304_29F4, 0x0A2C_86DA, 0xE9B6_6DFB,
            0x68DC_1462, 0xD748_6900, 0x680E_C0A4, 0x27A1_8DEE,
            0x4F3F_FEA2, 0xE887_AD8C, 0xB58C_E006, 0x7AF4_D6B6,
            0xAACE_1E7C, 0xD337_5FEC, 0xCE78_A399, 0x406B_2A42,
            0x20FE_9E35, 0xD9F3_85B9, 0xEE39_D7AB, 0x3B12_4E8B,
            0x1DC9_FAF7, 0x4B6D_1856, 0x26A3_6631, 0xEAE3_97B2,
            0x3A6E_FA74, 0xDD5B_4332, 0x6841_E7F7, 0xCA78_20FB,
            0xFB0A_F54E, 0xD8FE_B397, 0x4540_56AC, 0xBA48_9527,
            0x5553_3A3A, 0x2083_8D87, 0xFE6B_A9B7, 0xD096_954B,
            0x55A8_67BC, 0xA115_9A58, 0xCCA9_2963, 0x99E1_DB33,
            0xA62A_4A56, 0x3F31_25F9, 0x5EF4_7E1C, 0x9029_317C,
            0xFDF8_E802, 0x0427_2F70, 0x80BB_155C, 0x0528_2CE3,
            0x95C1_1548, 0xE4C6_6D22, 0x48C1_133F, 0xC70F_86DC,
            0x07F9_C9EE, 0x4104_1F0F, 0x4047_79A4, 0x5D88_6E17,
            0x325F_51EB, 0xD59B_C0D1, 0xF2BC_C18F, 0x4111_3564,
            0x257B_7834, 0x602A_9C60, 0xDFF8_E8A3, 0x1F63_6C1B,
            0x0E12_B4C2, 0x02E1_329E, 0xAF66_4FD1, 0xCAD1_8115,
            0x6B23_95E0, 0x333E_92E1, 0x3B24_0B62, 0xEEBE_B922,
            0x85B2_A20E, 0xE6BA_0D99, 0xDE72_0C8C, 0x2DA2_F728,
            0xD012_7845, 0x95B7_94FD, 0x647D_0862, 0xE7CC_F5F0,
            0x5449_A36F, 0x877D_48FA, 0xC39D_FD27, 0xF33E_8D1E,
            0x0A47_6341, 0x992E_FF74, 0x3A6F_6EAB, 0xF4F8_FD37,
            0xA812_DC60, 0xA1EB_DDF8, 0x991B_E14C, 0xDB6E_6B0D,
            0xC67B_5510, 0x6D67_2C37, 0x2765_D43B, 0xDCD0_E804,
            0xF129_0DC7, 0xCC00_FFA3, 0xB539_0F92, 0x690F_ED0B,
            0x667B_9FFB, 0xCEDB_7D9C, 0xA091_CF0B, 0xD915_5EA3,
            0xBB13_2F88, 0x515B_AD24, 0x7B94_79BF, 0x763B_D6EB,
            0x3739_2EB3, 0xCC11_5979, 0x8026_E297, 0xF42E_312D,
            0x6842_ADA7, 0xC66A_2B3B, 0x1275_4CCC, 0x782E_F11C,
            0x6A12_4237, 0xB792_51E7, 0x06A1_BBE6, 0x4BFB_6350,
            0x1A6B_1018, 0x11CA_EDFA, 0x3D25_BDD8, 0xE2E1_C3C9,
            0x4442_1659, 0x0A12_1386, 0xD90C_EC6E, 0xD5AB_EA2A,
            0x64AF_674E, 0xDA86_A85F, 0xBEBF_E988, 0x64E4_C3FE,
            0x9DBC_8057, 0xF0F7_C086, 0x6078_7BF8, 0x6003_604D,
            0xD1FD_8346, 0xF638_1FB0, 0x7745_AE04, 0xD736_FCCC,
            0x8342_6B33, 0xF01E_AB71, 0xB080_4187, 0x3C00_5E5F,
            0x77A0_57BE, 0xBDE8_AE24, 0x5546_4299, 0xBF58_2E61,
            0x4E58_F48F, 0xF2DD_FDA2, 0xF474_EF38, 0x8789_BDC2,
            0x5366_F9C3, 0xC8B3_8E74, 0xB475_F255, 0x46FC_D9B9,
            0x7AEB_2661, 0x8B1D_DF84, 0x846A_0E79, 0x915F_95E2,
            0x466E_598E, 0x20B4_5770, 0x8CD5_5591, 0xC902_DE4C,
            0xB90B_ACE1, 0xBB82_05D0, 0x11A8_6248, 0x7574_A99E,
            0xB77F_19B6, 0xE0A9_DC09, 0x662D_09A1, 0xC432_4633,
            0xE85A_1F02, 0x09F0_BE8C, 0x4A99_A025, 0x1D6E_FE10,
            0x1AB9_3D1D, 0x0BA5_A4DF, 0xA186_F20F, 0x2868_F169,
            0xDCB7_DA83, 0x5739_06FE, 0xA1E2_CE9B, 0x4FCD_7F52,
            0x5011_5E01, 0xA706_83FA, 0xA002_B5C4, 0x0DE6_D027,
            0x9AF8_8C27, 0x773F_8641, 0xC360_4C06, 0x61A8_06B5,
            0xF017_7A28, 0xC0F5_86E0, 0x0060_58AA, 0x30DC_7D62,
            0x11E6_9ED7, 0x2338_EA63, 0x53C2_DD94, 0xC2C2_1634,
            0xBBCB_EE56, 0x90BC_B6DE, 0xEBFC_7DA1, 0xCE59_1D76,
            0x6F05_E409, 0x4B7C_0188, 0x3972_0A3D, 0x7C92_7C24,
            0x86E3_725F, 0x724D_9DB9, 0x1AC1_5BB4, 0xD39E_B8FC,
            0xED54_5578, 0x08FC_A5B5, 0xD83D_7CD3, 0x4DAD_0FC4,
            0x1E50_EF5E, 0xB161_E6F8, 0xA285_14D9, 0x6C51_133C,
            0x6FD5_C7E7, 0x56E1_4EC4, 0x362A_BFCE, 0xDDC6_C837,
            0xD79A_3234, 0x9263_8212, 0x670E_FA8E, 0x4060_00E0,
        ],
        [
            0x3A39_CE37, 0xD3FA_F5CF, 0xABC2_7737, 0x5AC5_2D1B,
            0x5CB0_679E, 0x4FA3_3742, 0xD382_2740, 0x99BC_9BBE,
            0xD511_8E9D, 0xBF0F_7315, 0xD62D_1C7E, 0xC700_C47B,
            0xB78C_1B6B, 0x21A1_9045, 0xB26E_B1BE, 0x6A36_6EB4,
            0x5748_AB2F, 0xBC94_6E79, 0xC6A3_76D2, 0x6549_C2C8,
            0x530F_F8EE, 0x468D_DE7D, 0xD573_0A1D, 0x4CD0_4DC6,
            0x2939_BBDB, 0xA9BA_4650, 0xAC95_26E8, 0xBE5E_E304,
            0xA1FA_D5F0, 0x6A2D_519A, 0x63EF_8CE2, 0x9A86_EE22,
            0xC089_C2B8, 0x4324_2EF6, 0xA51E_03AA, 0x9CF2_D0A4,
            0x83C0_61BA, 0x9BE9_6A4D, 0x8FE5_1550, 0xBA64_5BD6,
            0x2826_A2F9, 0xA73A_3AE1, 0x4BA9_9586, 0xEF55_62E9,
            0xC72F_EFD3, 0xF752_F7DA, 0x3F04_6F69, 0x77FA_0A59,
            0x80E4_A915, 0x87B0_8601, 0x9B09_E6AD, 0x3B3E_E593,
            0xE990_FD5A, 0x9E34_D797, 0x2CF0_B7D9, 0x022B_8B51,
            0x96D5_AC3A, 0x017D_A67D, 0xD1CF_3ED6, 0x7C7D_2D28,
            0x1F9F_25CF, 0xADF2_B89B, 0x5AD6_B472, 0x5A88_F54C,
            0xE029_AC71, 0xE019_A5E6, 0x47B0_ACFD, 0xED93_FA9B,
            0xE8D3_C48D, 0x283B_57CC, 0xF8D5_6629, 0x7913_2E28,
            0x785F_0191, 0xED75_6055, 0xF796_0E44, 0xE3D3_5E8C,
            0x1505_6DD4, 0x88F4_6DBA, 0x03A1_6125, 0x0564_F0BD,
            0xC3EB_9E15, 0x3C90_57A2, 0x9727_1AEC, 0xA93A_072A,
            0x1B3F_6D9B, 0x1E63_21F5, 0xF59C_66FB, 0x26DC_F319,
            0x7533_D928, 0xB155_FDF5, 0x0356_3482, 0x8ABA_3CBB,
            0x2851_7711, 0xC20A_D9F8, 0xABCC_5167, 0xCCAD_925F,
            0x4DE8_1751, 0x3830_DC8E, 0x379D_5862, 0x9320_F991,
            0xEA7A_90C2, 0xFB3E_7BCE, 0x5121_CE64, 0x774F_BE32,
            0xA8B6_E37E, 0xC329_3D46, 0x48DE_5369, 0x6413_E680,
            0xA2AE_0810, 0xDD6D_B224, 0x6985_2DFD, 0x0907_2166,
            0xB39A_460A, 0x6445_C0DD, 0x586C_DECF, 0x1C20_C8AE,
            0x5BBE_F7DD, 0x1B58_8D40, 0xCCD2_017F, 0x6BB4_E3BB,
            0xDDA2_6A7E, 0x3A59_FF45, 0x3E35_0A44, 0xBCB4_CDD5,
            0x72EA_CEA8, 0xFA64_84BB, 0x8D66_12AE, 0xBF3C_6F47,
            0xD29B_E463, 0x542F_5D9E, 0xAEC2_771B, 0xF64E_6370,
            0x740E_0D8D, 0xE75B_1357, 0xF872_1671, 0xAF53_7D5D,
            0x4040_CB08, 0x4EB4_E2CC, 0x34D2_466A, 0x0115_AF84,
            0xE1B0_0428, 0x9598_3A1D, 0x06B8_9FB4, 0xCE6E_A048,
            0x6F3F_3B82, 0x3520_AB82, 0x011A_1D4B, 0x2772_27F8,
            0x6115_60B1, 0xE793_3FDC, 0xBB3A_792B, 0x3445_25BD,
            0xA088_39E1, 0x51CE_794B, 0x2F32_C9B7, 0xA01F_BAC9,
            0xE01C_C87E, 0xBCC7_D1F6, 0xCF01_11C3, 0xA1E8_AAC7,
            0x1A90_8749, 0xD44F_BD9A, 0xD0DA_DECB, 0xD50A_DA38,
            0x0339_C32A, 0xC691_3667, 0x8DF9_317C, 0xE0B1_2B4F,
            0xF79E_59B7, 0x43F5_BB3A, 0xF2D5_19FF, 0x27D9_459C,
            0xBF97_222C, 0x15E6_FC2A, 0x0F91_FC71, 0x9B94_1525,
            0xFAE5_9361, 0xCEB6_9CEB, 0xC2A8_6459, 0x12BA_A8D1,
            0xB6C1_075E, 0xE305_6A0C, 0x10D2_5065, 0xCB03_A442,
            0xE0EC_6E0E, 0x1698_DB3B, 0x4C98_A0BE, 0x3278_E964,
            0x9F1F_9532, 0xE0D3_92DF, 0xD3A0_342B, 0x8971_F21E,
            0x1B0A_7441, 0x4BA3_348C, 0xC5BE_7120, 0xC376_32D8,
            0xDF35_9F8D, 0x9B99_2F2E, 0xE60B_6F47, 0x0FE3_F11D,
            0xE54C_DA54, 0x1EDA_D891, 0xCE62_79CF, 0xCD3E_7E6F,
            0x1618_B166, 0xFD2C_1D05, 0x848F_D2C5, 0xF6FB_2299,
            0xF523_F357, 0xA632_7623, 0x93A8_3531, 0x56CC_CD02,
            0xACF0_8162, 0x5A75_EBB5, 0x6E16_3697, 0x88D2_73CC,
            0xDE96_6292, 0x81B9_49D0, 0x4C50_901B, 0x71C6_5614,
            0xE6C6_C7BD, 0x327A_140A, 0x45E1_D006, 0xC3F2_7B9A,
            0xC9AA_53FD, 0x62A8_0F00, 0xBB25_BFE2, 0x35BD_D2F6,
            0x7112_6905, 0xB204_0222, 0xB6CB_CF7C, 0xCD76_9C2B,
            0x5311_3EC0, 0x1640_E3D3, 0x38AB_BD60, 0x2547_ADF0,
            0xBA38_209C, 0xF746_CE76, 0x77AF_A1C5, 0x2075_6060,
            0x85CB_FE4E, 0x8AE8_8DD8, 0x7AAA_F9B0, 0x4CF9_AA7E,
            0x1948_C25C, 0x02FB_8A8C, 0x01C3_6AE4, 0xD6EB_E1F9,
            0x90D4_F869, 0xA65C_DEA0, 0x3F09_252D, 0xC208_E69F,
            0xB74E_6132, 0xCE77_E25B, 0x578F_DFE3, 0x3AC3_72E6,
        ],
    ]

    public init(key: [UInt8], blockMode: BlockMode = CBC(iv: [UInt8](repeating: 0, count: Blowfish.blockSize)), padding: Padding) throws {
        precondition(key.count >= 5 && key.count <= 56)

        self.blockMode = blockMode
        self.padding = padding
        keySize = key.count

        S = origS
        P = origP

        expandKey(key: key)
        try setupBlockModeWorkers()
    }

    private func setupBlockModeWorkers() throws {
        encryptWorker = try blockMode.worker(blockSize: Blowfish.blockSize, cipherOperation: encrypt)

        if blockMode.options.contains(.useEncryptToDecrypt) {
            decryptWorker = try blockMode.worker(blockSize: Blowfish.blockSize, cipherOperation: encrypt)
        } else {
            decryptWorker = try blockMode.worker(blockSize: Blowfish.blockSize, cipherOperation: decrypt)
        }
    }

    private func reset() {
        S = origS
        P = origP
        // todo expand key
    }

    private func expandKey(key: [UInt8]) {
        var j = 0
        for i in 0 ..< (N + 2) {
            var data: UInt32 = 0x0
            for _ in 0 ..< 4 {
                data = (data << 8) | UInt32(key[j])
                j += 1
                if j >= key.count {
                    j = 0
                }
            }
            P[i] ^= data
        }

        var datal: UInt32 = 0
        var datar: UInt32 = 0

        for i in stride(from: 0, to: N + 2, by: 2) {
            encryptBlowfishBlock(l: &datal, r: &datar)
            P[i] = datal
            P[i + 1] = datar
        }

        for i in 0 ..< 4 {
            for j in stride(from: 0, to: 256, by: 2) {
                encryptBlowfishBlock(l: &datal, r: &datar)
                S[i][j] = datal
                S[i][j + 1] = datar
            }
        }
    }

    fileprivate func encrypt(block: ArraySlice<UInt8>) -> [UInt8]? {
        var result = [UInt8]()

        var l = UInt32(bytes: block[block.startIndex ..< block.startIndex.advanced(by: 4)])
        var r = UInt32(bytes: block[block.startIndex.advanced(by: 4) ..< block.startIndex.advanced(by: 8)])

        encryptBlowfishBlock(l: &l, r: &r)

        // because everything is too complex to be solved in reasonable time o_O
        result += [
            UInt8((l >> 24) & 0xFF),
            UInt8((l >> 16) & 0xFF),
        ]
        result += [
            UInt8((l >> 8) & 0xFF),
            UInt8((l >> 0) & 0xFF),
        ]
        result += [
            UInt8((r >> 24) & 0xFF),
            UInt8((r >> 16) & 0xFF),
        ]
        result += [
            UInt8((r >> 8) & 0xFF),
            UInt8((r >> 0) & 0xFF),
        ]

        return result
    }

    fileprivate func decrypt(block: ArraySlice<UInt8>) -> [UInt8]? {
        var result = [UInt8]()

        var l = UInt32(bytes: block[block.startIndex ..< block.startIndex.advanced(by: 4)])
        var r = UInt32(bytes: block[block.startIndex.advanced(by: 4) ..< block.startIndex.advanced(by: 8)])

        decryptBlowfishBlock(l: &l, r: &r)

        // because everything is too complex to be solved in reasonable time o_O
        result += [
            UInt8((l >> 24) & 0xFF),
            UInt8((l >> 16) & 0xFF),
        ]
        result += [
            UInt8((l >> 8) & 0xFF),
            UInt8((l >> 0) & 0xFF),
        ]
        result += [
            UInt8((r >> 24) & 0xFF),
            UInt8((r >> 16) & 0xFF),
        ]
        result += [
            UInt8((r >> 8) & 0xFF),
            UInt8((r >> 0) & 0xFF),
        ]
        return result
    }

    /// Encrypts the 8-byte padded buffer
    ///
    /// - Parameters:
    ///   - l: left half
    ///   - r: right half
    private func encryptBlowfishBlock(l: inout UInt32, r: inout UInt32) {
        var Xl = l
        var Xr = r

        for i in 0 ..< N {
            Xl = Xl ^ P[i]
            Xr = F(x: Xl) ^ Xr

            (Xl, Xr) = (Xr, Xl)
        }

        (Xl, Xr) = (Xr, Xl)

        Xr = Xr ^ P[N]
        Xl = Xl ^ P[N + 1]

        l = Xl
        r = Xr
    }

    /// Decrypts the 8-byte padded buffer
    ///
    /// - Parameters:
    ///   - l: left half
    ///   - r: right half
    private func decryptBlowfishBlock(l: inout UInt32, r: inout UInt32) {
        var Xl = l
        var Xr = r

        for i in (2 ... N + 1).reversed() {
            Xl = Xl ^ P[i]
            Xr = F(x: Xl) ^ Xr

            (Xl, Xr) = (Xr, Xl)
        }

        (Xl, Xr) = (Xr, Xl)

        Xr = Xr ^ P[1]
        Xl = Xl ^ P[0]

        l = Xl
        r = Xr
    }

    private func F(x: UInt32) -> UInt32 {
        let f1 = S[0][Int(x >> 24) & 0xFF]
        let f2 = S[1][Int(x >> 16) & 0xFF]
        let f3 = S[2][Int(x >> 8) & 0xFF]
        let f4 = S[3][Int(x & 0xFF)]
        return ((f1 &+ f2) ^ f3) &+ f4
    }
}

extension Blowfish: Cipher {
    /// Encrypt the 8-byte padded buffer, block by block. Note that for amounts of data larger than a block, it is not safe to just call encrypt() on successive blocks.
    ///
    /// - Parameter bytes: Plaintext data
    /// - Returns: Encrypted data
    public func encrypt<C: Collection>(_ bytes: C) throws -> [UInt8] where C.Element == UInt8, C.Index == Int {
        let bytes = padding.add(to: Array(bytes), blockSize: Blowfish.blockSize) // FIXME: Array(bytes) copies

        var out = [UInt8]()
        out.reserveCapacity(bytes.count)

        for chunk in bytes.batched(by: Blowfish.blockSize) {
            out += encryptWorker.encrypt(block: chunk)
        }

        if blockMode.options.contains(.paddingRequired), out.count % Blowfish.blockSize != 0 {
            throw Error.dataPaddingRequired
        }

        return out
    }

    /// Decrypt the 8-byte padded buffer
    ///
    /// - Parameter bytes: Ciphertext data
    /// - Returns: Plaintext data
    public func decrypt<C: Collection>(_ bytes: C) throws -> [UInt8] where C.Element == UInt8, C.Index == Int {
        if blockMode.options.contains(.paddingRequired), bytes.count % Blowfish.blockSize != 0 {
            throw Error.dataPaddingRequired
        }

        var out = [UInt8]()
        out.reserveCapacity(bytes.count)

        for chunk in Array(bytes).batched(by: Blowfish.blockSize) {
            out += decryptWorker.decrypt(block: chunk) // FIXME: copying here is innefective
        }

        out = padding.remove(from: out, blockSize: Blowfish.blockSize)

        return out
    }
}
