<connectionStrings>
    <add name="Flight"
        providerName="System.Data.Sql"
        connectionString="Data Source=tcp:${ database_fqdn },1433;Initial Catalog=Flight;Persist Security Info=True;User ID=${ database_user };Password=${ database_password };" />
    <add name="Hotel"
        providerName="System.Data.Sql"
        connectionString="Data Source=tcp:${ database_fqdn },1433;Initial Catalog=Hotel;Persist Security Info=True;User ID=${ database_user };Password=${ database_password };" />
</connectionStrings>