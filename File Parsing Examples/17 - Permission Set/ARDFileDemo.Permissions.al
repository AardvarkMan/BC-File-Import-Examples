permissionset 50000 "ARD_FileDemo"
{
    Assignable = true;
    Permissions = tabledata ARD_CustomerStaging=RIMD,
        tabledata ARD_Pet=RIMD,
        tabledata ARD_PetOwner=RIMD,
        table ARD_CustomerStaging=X,
        table ARD_Pet=X,
        table ARD_PetOwner=X,
        page ARD_CustomerImport=X,
        page ARD_PetOwner=X,
        page ARD_PetOwners=X,
        page ARD_Pets=X,
        tabledata ARD_ItemStaging=RIMD,
        table ARD_ItemStaging=X,
        page ARD_ExcelImport=X,
        tabledata ARD_SalesDetail=RIMD,
        tabledata ARD_SalesHeader=RIMD,
        table ARD_SalesDetail=X,
        table ARD_SalesHeader=X;
}