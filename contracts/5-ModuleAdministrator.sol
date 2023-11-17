// ModuleAdministrator.sol for MODULE_ADMIN_ROLE

Responsible for adding, removing, or updating modules within the system, handling the modular architecture's integrity.

interface IModuleHook {
    function executeHook(address target, bytes calldata data) external returns (bool, bytes memory);
}
