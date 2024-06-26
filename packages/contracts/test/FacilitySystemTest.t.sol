// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Counter, CounterTableId, Position, PositionData } from "../src/codegen/index.sol";

contract FacilitySystemTest is MudTest {
  IWorld public world;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testBuildFacility() public {
    //build a facility with entityTypeId 10 at position (1,1,1) with yaw 0
    bytes32 entityKey01 = world.buildFacility(10, 1, 1, 1, 0);
    PositionData memory posData01 = Position.get(entityKey01);
    assertEq(posData01.x, 1);

    //revert if trying to build on occupied position
    vm.expectRevert(abi.encodePacked("Position is occupied"));
    world.buildFacility(10, 1, 1, 1, 0);

    //should be able to build on an unoccupied position
    bytes32 entityKey03 = world.buildFacility(10, 2, 1, 1, 0);
    PositionData memory posData03 = Position.get(entityKey03);
    assertEq(posData03.x, 2);
  }

  function testDestoryFacility() public {
    vm.expectRevert(abi.encodePacked("Sender does not own this entity"));
    world.destoryFacility(0);

    //build a facility with entityTypeId 10 at position (1,1,1) with yaw 0
    bytes32 entityKey01 = world.buildFacility(10, 1, 1, 1, 0);
    PositionData memory posData01 = Position.get(entityKey01);
    assertEq(posData01.x, 1);

    //destoryFacility should work as expected
    world.destoryFacility(entityKey01);
    PositionData memory posData01b = Position.get(entityKey01);
    assertNotEq(posData01b.x, 1);

    //should now be able to build on the same position after the original one was destoryed
    bytes32 entityKey02 = world.buildFacility(11, 1, 1, 1, 0);
    PositionData memory posData02 = Position.get(entityKey02);
    assertEq(posData02.x, 1);
  }
}
