// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import { Script } from "forge-std/Script.sol";
import { ERC1967Proxy } from "openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

import { SoundFeeRegistry } from "@core/SoundFeeRegistry.sol";
import { SoundEditionV1_1 } from "@core/SoundEditionV1_1.sol";
import { SoundCreatorV1 } from "@core/SoundCreatorV1.sol";
import { IMetadataModule } from "@core/interfaces/IMetadataModule.sol";
import { GoldenEggMetadata } from "@modules/GoldenEggMetadata.sol";
import { FixedPriceSignatureMinter } from "@modules/FixedPriceSignatureMinter.sol";
import { MerkleDropMinter } from "@modules/MerkleDropMinter.sol";
import { RangeEditionMinter } from "@modules/RangeEditionMinter.sol";
import { EditionMaxMinter } from "@modules/EditionMaxMinter.sol";
import { BasicMetadata } from "@modules/BasicMetadataModule.sol";

contract Deploy is Script {
    //bytes32 private SALT = bytes32(string(vm.envString("DEPLOY_SALT")));
    uint16 private PLATFORM_FEE_BPS = uint16(vm.envUint("PLATFORM_FEE_BPS"));
    address private PLATFORM_FEE_REGISTRY_ADDRES = address(vm.envAddress("PLATFORM_FEE_REGISTRY_ADDRES"));

    //bytes32 private superSalt = SALT;
    bytes32 private superSalt = bytes32("Ander was here. :) :)()()()");
    address feeRegistryAddr = PLATFORM_FEE_REGISTRY_ADDRES;
    uint16 feeRegistryBPS = PLATFORM_FEE_BPS;

    function run() external {
        vm.startBroadcast();

        //////////////////// Sound Edition v1_1 ///////////////////////////////////////////
        SoundEditionV1_1 editionImplementation = new SoundEditionV1_1{ salt: superSalt }();
        editionImplementation.initialize(
            "SoundEditionV1.1.0", // name
            "SOUND", // symbol
            address(0),
            "baseURI",
            "contractURI",
            address(1), // fundingRecipient
            0, // royaltyBPS
            0, // editionMaxMintableLower
            0, // editionMaxMintableUpper
            0, // editionCutoffTime
            editionImplementation.MINT_RANDOMNESS_ENABLED_FLAG() // flags
        );
        ///////////////////////////////////////////////////////////////////////////////////

        //////////////////////  SoundCreator //////////////////////////////////////////////
        //SoundCreatorV1 soundCreator = new SoundCreatorV1(address(0xeA422fe2dC58c6DDEfF7362612595458f545113c));
        SoundCreatorV1 soundCreator = new SoundCreatorV1{ salt: superSalt }(address(editionImplementation));
        ///////////////////////////////////////////////////////////////////////////////////

        //////////////////////  Fee registry //////////////////////////////////////////////
        SoundFeeRegistry soundFeeRegistry = new SoundFeeRegistry{ salt: superSalt }(feeRegistryAddr, feeRegistryBPS);
        ///////////////////////////////////////////////////////////////////////////////////

        //////////////////////  EditionMaxMinter //////////////////////////////////////////
        EditionMaxMinter editionMaxMinter = new EditionMaxMinter{ salt: superSalt }(soundFeeRegistry);
        ////////////////////////////////////////////////////////////////////////////////////

        //////////////////////  FixedPriceSignatureMinter //////////////////////////////////
        FixedPriceSignatureMinter fixedPriceSignature = new FixedPriceSignatureMinter{ salt: superSalt }(
            soundFeeRegistry
        );
        /////////////////////////////////////////////////////////////////////////////////////

        //////////////////////  GoldenEggMetadata ///////////////////////////////////////////
        GoldenEggMetadata goldenEggMetadata = new GoldenEggMetadata{ salt: superSalt }();
        /////////////////////////////////////////////////////////////////////////////////////

        //////////////////////  MerkleDropMinter ////////////////////////////////////////////
        MerkleDropMinter merkleDrop = new MerkleDropMinter{ salt: superSalt }(soundFeeRegistry);
        //////////////////////////////////////////////////////////////////////////////////////

        //////////////////////  RangeEditionMinter ///////////////////////////////////////////
        RangeEditionMinter rangeEdition = new RangeEditionMinter{ salt: superSalt }(soundFeeRegistry);
        //////////////////////////////////////////////////////////////////////////////////////

        //////////////////////  BasicMetadata     ////////////////////////////////////////////
        BasicMetadata basicMetadata = new BasicMetadata{ salt: superSalt }();
        //////////////////////////////////////////////////////////////////////////////////////

        vm.stopBroadcast();
    }
}
