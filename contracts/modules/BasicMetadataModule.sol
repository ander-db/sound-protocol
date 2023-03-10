// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IMetadataModule } from "@core/interfaces/IMetadataModule.sol";
import { ISoundEditionV1_1 } from "@core/interfaces/ISoundEditionV1_1.sol";

contract BasicMetadata is IMetadataModule {
    function tokenURI(uint256) external view returns (string memory) {
        string memory baseURI = ISoundEditionV1_1(msg.sender).baseURI();

        return baseURI;
    }
}
