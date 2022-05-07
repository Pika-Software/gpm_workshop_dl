if (CLIENT) then
    return
end

do

    local resource_AddWorkshop = environment.saveFunc( "resource.AddWorkshop", resource.AddWorkshop )
    local table_insert = table.insert
    local ipairs = ipairs
    local Msg = Msg

    local workshop = {}

    --[[-------------------------------------------------------------------------
        `table` resource.GetWorkshop()
    ---------------------------------------------------------------------------]]
    function resource.GetWorkshop()
        return workshop
    end

    --[[-------------------------------------------------------------------------
        `boolean` resource.HasWorkshop( `string` id )
    ---------------------------------------------------------------------------]]

    function resource.HasWorkshop( id )
        for num, id in ipairs( workshop ) do
            if (wsid == id) then
                return true
            end
        end

        return false
    end

    --[[-------------------------------------------------------------------------
        resource.AddWorkshop( `string` id )
    ---------------------------------------------------------------------------]]
    function resource.AddWorkshop( ... )

        local item_list = {}
        for num, wsid in ipairs({...}) do
            if resource.HasWorkshop( wsid ) then
                continue
            end

            local installed = engine.GetAddon( wsid )
            if (installed ~= nil) then
                table_insert( workshop, wsid )
                resource_AddWorkshop( wsid )
                Msg( "+ Addon: " .. installed.title .. " (" .. wsid .. ")\n")
            elseif (steam ~= nil) and (steam.GetWorkshopItemInfo ~= nil) then
                table_insert( item_list, wsid )
            else
                table_insert( workshop, wsid )
                resource_AddWorkshop( wsid )
                Msg( "+ Addon: N/A (" .. wsid .. ")\n")
            end
        end

        if (#item_list > 0) then
            steam.GetWorkshopItemInfo(function( addons )
                for num, addon in ipairs( addons ) do
                    local wsid = addon.publishedfileid
                    if (addon.title == nil) then
                        Msg( "+ Addon: Hidden (" .. wsid .. ")\n" )
                    else
                        Msg( "+ Addon: " .. addon.title .. " (" .. wsid .. ")\n" )
                    end

                    resource_AddWorkshop( wsid )
                    table_insert( workshop, wsid )
                end
            end, unpack( item_list ) )
        end

    end

end

--[[-------------------------------------------------------------------------
    resource.AddWorkshopCollection( `string` id )
---------------------------------------------------------------------------]]

function resource.AddWorkshopCollection( ... )
    local used_collections = {}
    steam.GetCollectionDetails( function( result )
        local collections = {}

        for num, collection in ipairs( result ) do
            if (collection.children == nil) then continue end
            local wsid = collection.publishedfileid
            if (used_collections[ wsid ] == true) then continue end
            used_collections[ wsid ] = true

            local addons = {}
            for num, item in ipairs( collection.children ) do
                if (item.filetype == 0) then
                    if resource.HasWorkshop( item.publishedfileid ) then continue end
                    table.insert( addons, item.publishedfileid )
                elseif (item.filetype == 2) then
                    table.insert( collections, item.publishedfileid )
                end
            end

            MsgN( "\nAdding " .. #addons .. " addons to WorkshopDL from collection (" .. wsid .. ")" )
            if (#addons > 0) then
                resource.AddWorkshop( unpack( addons ) )
            end
        end

        if (#collections > 0) then
            resource.AddWorkshopCollection( unpack( collections ) )
        end
    end, ... )
end