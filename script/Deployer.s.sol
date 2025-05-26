// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {IERC20} from "@chainlink-brownie/contracts/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {RegistryModuleOwnerCustom} from
    "@chainlink-brownie/contracts/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@chainlink-brownie/contracts/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";

import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";

contract TokenAndPoolDeployer is Script {
    function run() public returns (RebaseToken token, RebaseTokenPool pool) {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startBroadcast();
        token = new RebaseToken();
        pool = new RebaseTokenPool(
            IERC20(address(token)), new address[](0), networkDetails.rmnProxyAddress, networkDetails.routerAddress
        );

        console.log("RebaseToken deployed at: ", address(token));
        console.log("RebaseTokenPool deployed at: ", address(pool));
        vm.stopBroadcast();
    }
}

contract SetRole is Script {
    function run(address _rebaseToken, address _rebaseTokenPool) public {
        grantRole(_rebaseToken, _rebaseTokenPool);
    }

    function grantRole(address _rebaseToken, address _rebaseTokenPool) public {
        vm.startBroadcast();
        IRebaseToken(_rebaseToken).grantMintAndBurnRole(address(_rebaseTokenPool));
        vm.stopBroadcast();
    }
}

contract SetRegistryModuleOwnerCustom is Script {
    function run(address _rebaseToken) public {
        setRegistryModuleOwnerCustom(_rebaseToken);
    }

    function setRegistryModuleOwnerCustom(address _rebaseToken) public {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startBroadcast();
        // IRebaseToken(_rebaseToken).grantMintAndBurnRole(address(_rebaseTokenPool));
        RegistryModuleOwnerCustom(networkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(
            address(_rebaseToken)
        );
        // TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(_rebaseToken));
        // TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(address(_rebaseToken), address(_rebaseTokenPool));
        vm.stopBroadcast();
    }
}

contract SetTokenAdminRegistryToAcceptAdminRole is Script {
    function run(address _rebaseToken) public {
        acceptAdminRole(_rebaseToken);
    }

    function acceptAdminRole(address _rebaseToken) public {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startBroadcast();
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(_rebaseToken));
        vm.stopBroadcast();
    }
}

contract SetTokenAdminRegistryToSetPool is Script {
    function run(address _rebaseToken, address _rebaseTokenPool) public {
        setPool(_rebaseToken, _rebaseTokenPool);
    }

    function setPool(address _rebaseToken, address _rebaseTokenPool) public {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startBroadcast();
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(
            address(_rebaseToken), address(_rebaseTokenPool)
        );
        vm.stopBroadcast();
    }
}

contract VaultDeployer is Script {
    function run(address _iRebaseToken) public returns (Vault vault) {
        vm.startBroadcast();
        vault = new Vault(IRebaseToken(_iRebaseToken));
        IRebaseToken(_iRebaseToken).grantMintAndBurnRole(address(vault));
        vm.stopBroadcast();
    }
}
