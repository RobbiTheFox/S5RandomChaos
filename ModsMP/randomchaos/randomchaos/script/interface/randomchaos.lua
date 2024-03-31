--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- TODO:
-- reset memory on leave
RandomChaos = {}
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.InitAll()
    math.randomseed(math.floor(XGUIEng.GetSystemTime()*100000))
    RandomChaos.SetupMilitary()
    RandomChaos.SetupTechnologies()
    RandomChaos.SetupCosts()
    RandomChaos.SetupResources()
    RandomChaos.SetupStartResources()
    RandomChaos.SetupExtractionValues()
    RandomChaos.SetupSerfMenu()
    RandomChaos.SetupMotivationBuildings()
    RandomChaos.SetupTrading()
    RandomChaos.SetupTaxes()
    RandomChaos.SetupHeroes()
    RandomChaos.SetupBlessSettlers()
    RandomChaos.SetupWeatherChange()
    --RandomChaos.SetupLogic()
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- must be called before SetupTechnologies!
function RandomChaos.SetupMilitary()
    
    CUtil.DisableAutoUpgradeForTroops()
    function GameCallback_OnTechnologyResearched(_PlayerID, _TechnologyType)
        --Update Techs for Tech Race game mode in MP
        if XNetwork ~= nil 
        and XNetwork.GameInformation_GetMPFreeGameMode() == 2 then
            VC_OnTechnologyResearched( _PlayerID, _TechnologyType )
        end
        
        --calculate score
        if Score ~= nil then
            Score.CallBackResearched( _PlayerID, _TechnologyType )	
        end
        
        local PlayerID = GUI.GetPlayerID()
        if PlayerID ~= _PlayerID then
            return
        end
        
        local BuildingID = GUI.GetSelectedEntity()
        if BuildingID ~= 0 then
            local TechnologyAtBuilding = Logic.GetTechnologyResearchedAtBuilding(BuildingID)
            if  TechnologyAtBuilding == 0 then	
                XGUIEng.ShowWidget(gvGUI_WidgetID.ResearchInProgress,0)
            end
        end

        local upgradecategory = RandomChaos.TechnologyToUpgradeCategory[_TechnologyType]
        if upgradecategory then
            table.insert(RandomChaos.UpgradeCategories[upgradecategory[1]], upgradecategory[2])
        end

        --Do not play sound on begin of the map
        local GameTimeMS = Logic.GetTimeMs()	
        if GameTimeMS == 0 then
            return
        end
        
        --Update all buttons in the visible container
        XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
    end

    RandomChaos.UpgradeCategories = {
        {UpgradeCategories.LeaderBow},
        {UpgradeCategories.LeaderCavalry},
        {UpgradeCategories.LeaderHeavyCavalry},
        {UpgradeCategories.LeaderPoleArm},
        {UpgradeCategories.LeaderRifle},
        {UpgradeCategories.LeaderSword},
        {UpgradeCategories.Cannon1, UpgradeCategories.Cannon2, UpgradeCategories.Cannon3, UpgradeCategories.Cannon4},
        {UpgradeCategories.Scout, UpgradeCategories.Thief}--, UpgradeCategories.BattleSerf},
    }
    RandomChaos.TechnologyToUpgradeCategory = {
        [Technologies.T_UpgradeBow1] = {1, UpgradeCategories.LeaderBow2},
        [Technologies.T_UpgradeBow2] = {1, UpgradeCategories.LeaderBow3},
        [Technologies.T_UpgradeBow3] = {1, UpgradeCategories.LeaderBow4},
        [Technologies.T_UpgradeLightCavalry1] = {2, UpgradeCategories.LeaderCavalry2},
        [Technologies.T_UpgradeHeavyCavalry1] = {3, UpgradeCategories.LeaderHeavyCavalry2},
        [Technologies.T_UpgradeSpear1] = {4, UpgradeCategories.LeaderPoleArm2},
        [Technologies.T_UpgradeSpear2] = {4, UpgradeCategories.LeaderPoleArm3},
        [Technologies.T_UpgradeSpear3] = {4, UpgradeCategories.LeaderPoleArm4},
        [Technologies.T_UpgradeRifle1] = {5, UpgradeCategories.LeaderRifle2},
        [Technologies.T_UpgradeSword1] = {6, UpgradeCategories.LeaderSword2},
        [Technologies.T_UpgradeSword2] = {6, UpgradeCategories.LeaderSword3},
        [Technologies.T_UpgradeSword3] = {6, UpgradeCategories.LeaderSword4},
    }

    function RandomChaos.SetNextUpgradeCategory()
        local unittype = RandomChaos.UpgradeCategories[GetRandom_Client(1, table.getn(RandomChaos.UpgradeCategories))]
        RandomChaos.NextUpgradeCategory = unittype[GetRandom_Client(1, table.getn(unittype))]
    end
    
    -- set once with math.random, since Logic.GetRandom does not work this early
    local unittype = RandomChaos.UpgradeCategories[math.random(table.getn(RandomChaos.UpgradeCategories))]
    RandomChaos.NextUpgradeCategory = unittype[math.random(table.getn(unittype))]

    RandomChaos.GUIAction_BuyMilitaryUnit = GUIAction_BuyMilitaryUnit
    function GUIAction_BuyMilitaryUnit(_UpgradeCategory)
        RandomChaos.GUIAction_BuyMilitaryUnit(RandomChaos.NextUpgradeCategory)
        RandomChaos.SetNextUpgradeCategory()
    end

    RandomChaos.GUITooltip_BuyMilitaryUnit = GUITooltip_BuyMilitaryUnit
    function GUITooltip_BuyMilitaryUnit(_UpgradeCategory, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut)
        RandomChaos.GUITooltip_BuyMilitaryUnit(RandomChaos.NextUpgradeCategory, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut)
    end

    -- disable expel leaders
    RandomChaos.ExpelSettler = GUI.ExpelSettler
    function GUI.ExpelSettler(_Id)
        if Logic.IsLeader(_Id) == 0 then
            RandomChaos.ExpelSettler(_Id)
        end
    end

    RandomChaos.GameCallback_GUI_SelectionChanged = GameCallback_GUI_SelectionChanged
    function GameCallback_GUI_SelectionChanged()
        RandomChaos.GameCallback_GUI_SelectionChanged()
        if Logic.IsLeader(GUI.GetSelectedEntity()) == 0 then
            XGUIEng.DisableButton("Command_Expel", 0)
        else
            XGUIEng.DisableButton("Command_Expel", 1)
        end
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupTechnologies()

    -- 3 types: university, self research, worker research
    -- TODO: assign correct method and merge self and worker research
    local technologiestoswap = {
        {
            [Technologies.GT_Construction] = 0,
            [Technologies.GT_GearWheel] = 0,
            [Technologies.GT_ChainBlock] = 0,
            [Technologies.GT_Architecture] = 0,
            [Technologies.GT_Literacy] = 0,
            [Technologies.GT_Trading] = 0,
            [Technologies.GT_Printing] = 0,
            [Technologies.GT_Library] = 0,
            [Technologies.GT_Alchemy] = 0,
            [Technologies.GT_Alloying] = 0,
            [Technologies.GT_Metallurgy] = 0,
            [Technologies.GT_Chemistry] = 0,
            [Technologies.GT_Mercenaries] = 0,
            [Technologies.GT_StandingArmy] = 0,
            [Technologies.GT_Tactics] = 0,
            [Technologies.GT_Strategies] = 0,
            [Technologies.GT_Mathematics] = 0,
            [Technologies.GT_Binocular] = 0,
            [Technologies.GT_Matchlock] = 0,
            [Technologies.GT_PulledBarrel] = 0,
        },
        {
            [Technologies.T_BetterTrainingArchery] = 0,
            [Technologies.T_UpgradeBow1] = 0,
            [Technologies.T_UpgradeBow2] = 0,
            [Technologies.T_UpgradeBow3] = 0,
            [Technologies.T_UpgradeRifle1] = 0,
        
            [Technologies.T_BetterTrainingBarracks] = 0,
            [Technologies.T_UpgradeSpear1] = 0,
            [Technologies.T_UpgradeSpear2] = 0,
            [Technologies.T_UpgradeSpear3] = 0,
            [Technologies.T_UpgradeSword1] = 0,
            [Technologies.T_UpgradeSword2] = 0,
            [Technologies.T_UpgradeSword3] = 0,
        
            [Technologies.T_Shoeing] = 0,
            [Technologies.T_UpgradeHeavyCavalry1] = 0,
            [Technologies.T_UpgradeLightCavalry1] = 0,
            [Technologies.T_BetterChassis] = 0,
        
            [Technologies.T_ScoutFindResources] = 0,
            [Technologies.T_ScoutTorches] = 0,
            [Technologies.T_ThiefSabotage] = 0,
        
            [Technologies.T_TownGuard] = 0,
            [Technologies.T_Loom] = 0,
            [Technologies.T_Shoes] = 0,
            [Technologies.T_Tracking] = 0,
        },
        {
            [Technologies.T_BlisteringCannonballs] = 0,
            [Technologies.T_EnhancedGunPowder] = 0,
            [Technologies.T_WeatherForecast] = 0,
            [Technologies.T_ChangeWeather] = 0,
        
            [Technologies.T_LeatherMailArmor] = 0,
            [Technologies.T_ChainMailArmor] = 0,
            [Technologies.T_PlateMailArmor] = 0,
            [Technologies.T_SoftArcherArmor] = 0,
            [Technologies.T_PaddedArcherArmor] = 0,
            [Technologies.T_LeatherArcherArmor] = 0,
            [Technologies.T_IronCasting] = 0,
            [Technologies.T_MasterOfSmithery] = 0,
        
            [Technologies.T_Sights] = 0,
            [Technologies.T_LeadShot] = 0,
            [Technologies.T_FleeceArmor] = 0,
            [Technologies.T_FleeceLinedLeatherArmor] = 0,
        
            [Technologies.T_Fletching] = 0,
            [Technologies.T_BodkinArrow] = 0,
            [Technologies.T_WoodAging] = 0,
            [Technologies.T_Turnery] = 0,
        
            [Technologies.T_Masonry] = 0,
        },
    }
    for i = 1,3 do
        -- create technologies table to randomly pick from
        local technologies = {}
        for technology, _ in pairs(technologiestoswap[i]) do
            table.insert(technologies, technology)
        end

        -- assign random technologies
        -- TODO: Construction and Alchemy max T3
        for technology, _ in pairs(technologiestoswap[i]) do
            local randomindex = math.random(table.getn(technologies))
            technologiestoswap[i][technology] = technologies[randomindex]
            table.remove(technologies, randomindex)
        end
        
        -- replace technology conditions in memory
        for technology, _ in pairs(technologiestoswap[i]) do
            local technologycondition = CUtilMemory.GetMemory(8758176)[0][13][1][technology-1][23]
            if technologycondition:GetInt() ~= 0 then
                technologycondition[0]:SetInt(technologiestoswap[i][technologycondition[0]:GetInt()])
            end
        end
        
        -- backup conditions from memory
        local conditions = {}
        for technology, _ in pairs(technologiestoswap[i]) do
            local condition = CUtilMemory.GetMemory(8758176)[0][13][1][technology-1]
            conditions[technology] = {}
            for i = 21, 40 do
                conditions[technology][i] = condition[i]:GetInt()
            end
        end

        -- replace conditions in memory
        for technology, swap in pairs(technologiestoswap[i]) do
            local condition = CUtilMemory.GetMemory(8758176)[0][13][1][swap-1]
            local swapcondition = conditions[technology]
            for i = 21, 40 do
                condition[i]:SetInt(swapcondition[i])
            end
        end
    end

    -- reassign Technologies table
    for key, technology in pairs(Technologies) do
        local swap = technologiestoswap[1][technology] or technologiestoswap[2][technology] or technologiestoswap[3][technology]
        if swap then
            Technologies[key] = swap
        end
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupCosts()
    -- technologies
    local technologycostindices = {
        4,8,10,12,14,16,
    }
    local summedcosts = {}
    for _, technology in pairs(Technologies) do
        summedcosts[technology] = 0
        local technologycosts = CUtilMemory.GetMemory(8758176)[0][13][1][technology-1]
        for _, costindex in ipairs(technologycostindices) do
            summedcosts[technology] = summedcosts[technology] + technologycosts[costindex]:GetFloat()
            technologycosts[costindex]:SetFloat(0)
        end
        -- reset silver
        technologycosts[6]:SetFloat(0)

        local amountofdifferentresources = 2
        local costindices2 = {}
        while table.getn(costindices2) < amountofdifferentresources do
            table.addunique(costindices2,technologycostindices[math.random(table.getn(technologycostindices))])
        end
        local costsperresource = summedcosts[technology] / amountofdifferentresources
        local costmin, costmax = costsperresource * 0.5, costsperresource * 1.5
        for _, costindex in ipairs(costindices2) do
            technologycosts[costindex]:SetFloat(math.random(costmin, costmax))
        end
    end

    -- entities
    local settlercostindices = {
        41,45,47,49,51,53,
    }
    local buildingconstructioncostindices = {
        57,61,63,65,67,69,
    }
    local buildingupgradecostindices = {
        82,86,88,90,92,94,
    }
    for _, entitytype in pairs(Entities) do
        local typename = Logic.GetEntityTypeName(entitytype)

        -- settlers
        if (string.find(typename, "PU_") or string.find(typename, "PV_")) and (not(entitytype == Entities.PU_Hero2_Cannon1 or entitytype == Entities.PU_Hero2_Foundation1 or entitytype == Entities.PU_Hero3_Trap or entitytype == Entities.PU_Hero3_TrapCannon)) then
            summedcosts[entitytype] = 0
            local entitycosts = CUtilMemory.GetMemory(9002416)[0][7][entitytype]
            for _, costindex in ipairs(settlercostindices) do
                summedcosts[entitytype] = summedcosts[entitytype] + entitycosts[costindex]:GetFloat()
                entitycosts[costindex]:SetFloat(0)
            end
            -- reset silver
            entitycosts[6]:SetFloat(0)
    
            local amountofdifferentresources = math.floor(math.random(4,6)/2)
            local costindices2 = {}
            while table.getn(costindices2) < amountofdifferentresources do
                table.addunique(costindices2,settlercostindices[math.random(table.getn(settlercostindices))])
            end
            local costsperresource = (summedcosts[entitytype] / amountofdifferentresources)
            local costmin, costmax = costsperresource * 0.5, costsperresource * 1.5
            for _, costindex in ipairs(costindices2) do
                entitycosts[costindex]:SetFloat(math.random(costmin, costmax))
            end

        -- buildings
        elseif string.find(typename, "PB_") and (not(entitytype == Entities.PB_DarkTower2_Ballista or entitytype == Entities.PB_DarkTower3_Cannon or entitytype == Entities.PB_Tower2_Ballista or entitytype == Entities.PB_Tower3_Cannon)) then
            -- construction costs
            summedcosts[entitytype] = 0
            local entitycosts = CUtilMemory.GetMemory(9002416)[0][7][entitytype]
            for _, costindex in ipairs(buildingconstructioncostindices) do
                summedcosts[entitytype] = summedcosts[entitytype] + entitycosts[costindex]:GetFloat()
                entitycosts[costindex]:SetFloat(0)
            end
            -- reset silver
            entitycosts[6]:SetFloat(0)
    
            local amountofdifferentresources = math.floor(math.random(4,6)/2)
            local costindices2 = {}
            while table.getn(costindices2) < amountofdifferentresources do
                table.addunique(costindices2,buildingconstructioncostindices[math.random(table.getn(buildingconstructioncostindices))])
            end
            local costsperresource = (summedcosts[entitytype] / amountofdifferentresources)
            local costmin, costmax = costsperresource * 0.5, costsperresource * 1.5
            for _, costindex in ipairs(costindices2) do
                entitycosts[costindex]:SetFloat(math.random(costmin, costmax))
            end

            -- upgrade costs
            summedcosts[entitytype] = 0
            local entitycosts = CUtilMemory.GetMemory(9002416)[0][7][entitytype]
            for _, costindex in ipairs(buildingupgradecostindices) do
                summedcosts[entitytype] = summedcosts[entitytype] + entitycosts[costindex]:GetFloat()
                entitycosts[costindex]:SetFloat(0)
            end
            -- reset silver
            entitycosts[6]:SetFloat(0)
    
            local amountofdifferentresources = math.random(2,3)
            local costindices2 = {}
            while table.getn(costindices2) < amountofdifferentresources do
                table.addunique(costindices2,buildingupgradecostindices[math.random(table.getn(buildingupgradecostindices))])
            end
            local costsperresource = (summedcosts[entitytype] / amountofdifferentresources)
            local costmin, costmax = costsperresource * 0.5, costsperresource * 1.5
            for _, costindex in ipairs(costindices2) do
                entitycosts[costindex]:SetFloat(math.random(costmin, costmax))
            end
        end
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupResources()

    function RandomChaos_ResourceCreated()
        local id = Event.GetEntityID()
        if CUtil.GetEntityClass(id) == tonumber("76FEA4", 16) then
            RandomChaos.SetRandomResourceAmount(id)
        end
    end
    
    function RandomChaos.SetRandomResourceAmount(_Id)
        
        if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_Id)), "Bridge") then
            return
        end

        local amount = 0
        if Logic.GetEntityType(_Id) == Entities.XD_ResourceTree then
            -- tree
            amount = math.random(25,100)
        elseif Logic.IsEntityInCategory(_Id, EntityCategories.ResourcePit) == 1 then
            -- pit
            amount = math.random(20000,60000)
        else
            -- pile
            amount = math.random(2000,6000)
        end
    
        Logic.SetResourceDoodadGoodAmount(_Id, amount)
    end
    function RandomChaos.SetRandomResourceType(_Id)
        
        if string.find(Logic.GetEntityTypeName(Logic.GetEntityType(_Id)), "Bridge") then
            return
        end
        
        local resoucretypepointer = CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_Id))[66]
        resoucretypepointer:SetInt(RandomChaos.RawResourceTypes[resoucretypepointer:GetInt()] or resoucretypepointer:GetInt())
    end
    
    -- assign random resource types
    RandomChaos.RawResourceTypes = {
        [ResourceType.GoldRaw] = 0,
        [ResourceType.ClayRaw] = 0,
        [ResourceType.WoodRaw] = 0,
        [ResourceType.StoneRaw] = 0,
        [ResourceType.IronRaw] = 0,
        [ResourceType.SulfurRaw] = 0,
    }
    local resourcetypes = {
        ResourceType.GoldRaw,
        ResourceType.ClayRaw,
        ResourceType.WoodRaw,
        ResourceType.StoneRaw,
        ResourceType.IronRaw,
        ResourceType.SulfurRaw,
    }
    for k, v in pairs(RandomChaos.RawResourceTypes) do
        local index = math.random(table.getn(resourcetypes))
        RandomChaos.RawResourceTypes[k] = resourcetypes[index]
        table.remove(resourcetypes, index)
    end

    -- apply resource type to existing entities
    for id in CEntityIterator.Iterator(CEntityIterator.OfClassFilter(tonumber("76FEA4", 16))) do
        RandomChaos.SetRandomResourceType(id)
        RandomChaos.SetRandomResourceAmount(id)
    end

    local resourceentities = {
        Entities.XD_ClayPit1,
        Entities.XD_Clay1,
        Entities.XD_StonePit1,
        Entities.XD_Stone1,
        Entities.XD_Stone_BlockPath,
        Entities.XD_IronPit1,
        Entities.XD_Iron1,
        Entities.XD_SulfurPit1,
        Entities.XD_Sulfur1,
        -- dont change trees here, since WoodRaw is hardcoded
        --Entities.XD_ResourceTree,
    }
    for _, resourceentity in pairs(resourceentities) do
        local resouredoodadbehavior = GetEntityTypeBehaviorProperties(resourceentity, 7818560)[6]
        resouredoodadbehavior:SetInt(RandomChaos.RawResourceTypes[resouredoodadbehavior:GetInt()] or resouredoodadbehavior:GetInt())
    end
    
    -- set resource amount to newly created resource doodads
    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, "RandomChaos_ResourceCreated", 1, nil, nil)

    -- hack payday for gold
    function GameCallback_PaydayPayed(_PlayerId, _Amount)
        RandomChaos.AddToPlayersGlobalResource(_PlayerId, RandomChaos.RawResourceTypes[ResourceType.GoldRaw], _Amount)
        return 0
    end

    -- hack resource extracted for trees
    function GameCallback_GainedResourcesExtended(_ExtractorId, _ResourceId, _ResourceType, _Amount)
        if Logic.GetEntityType(_ExtractorId) == Entities.PU_Serf and Logic.GetEntityType(_ResourceId) == Entities.XD_ResourceTree then
            _ResourceType = RandomChaos.RawResourceTypes[_ResourceType]
        end
        return _ExtractorId, _ResourceId, _ResourceType, _Amount
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupStartResources()

    RandomChaos.AddToPlayersGlobalResource = Logic.AddToPlayersGlobalResource
    function Logic.AddToPlayersGlobalResource() end

    function RandomChaos.SetRandomResourcesForPlayer(_Player)
        for _, resourcetype in pairs(ResourceType) do
            RandomChaos.AddToPlayersGlobalResource(_Player, resourcetype, -Logic.GetPlayersGlobalResource(_Player, resourcetype))
        end
        for resourcetype, _ in pairs(RandomChaos.RawResourceTypes) do
            RandomChaos.AddToPlayersGlobalResource(_Player, resourcetype, math.random(350, 1850))
        end
    end

    if XNetwork.Manager_DoesExist() == 1 then
        local np = CNetwork and 16 or 8
        for p = 1, np do
            if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(p) == 1 then
                RandomChaos.SetRandomResourcesForPlayer(p)
            end
        end
    else
        RandomChaos.SetRandomResourcesForPlayer(GUI.GetPlayerID())
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- must be called after SetupResources
function RandomChaos.SetupExtractionValues()

    local minebuildings = {
        {
            Entities.PB_ClayMine1,
            Entities.PB_ClayMine2,
            Entities.PB_ClayMine3,
        },
        {
            Entities.PB_StoneMine1,
            Entities.PB_StoneMine2,
            Entities.PB_StoneMine3,
        },
        {
            Entities.PB_IronMine1,
            Entities.PB_IronMine2,
            Entities.PB_IronMine3,
        },
        {
            Entities.PB_SulfurMine1,
            Entities.PB_SulfurMine2,
            Entities.PB_SulfurMine3,
        },
    }
    for _,v in ipairs(minebuildings) do
        local minevalue = math.random(3,5)
        for _,minebuilding in ipairs(v) do
            CLogic.SetMinedResourcesValue(minebuilding, minevalue)
            minevalue = minevalue + math.random(0,2)
        end
    end

    RandomChaos.ResourceTypes = {
        [ResourceType.Gold] = RandomChaos.RawResourceTypes[ResourceType.GoldRaw] - 1,
        [ResourceType.Clay] = RandomChaos.RawResourceTypes[ResourceType.ClayRaw] - 1,
        [ResourceType.Wood] = RandomChaos.RawResourceTypes[ResourceType.WoodRaw] - 1,
        [ResourceType.Stone] = RandomChaos.RawResourceTypes[ResourceType.StoneRaw] - 1,
        [ResourceType.Iron] = RandomChaos.RawResourceTypes[ResourceType.IronRaw] - 1,
        [ResourceType.Sulfur] = RandomChaos.RawResourceTypes[ResourceType.SulfurRaw] - 1,
    }
    local refinebuildings = {
        {
            Entities.PB_Alchemist1,
            Entities.PB_Alchemist2,
        },
        {
            Entities.PB_Bank1,
            Entities.PB_Bank2,
        },
        {
            Entities.PB_Blacksmith1,
            Entities.PB_Blacksmith2,
            Entities.PB_Blacksmith3,
        },
        {
            Entities.PB_Brickworks1,
            Entities.PB_Brickworks2,
        },
        {
            Entities.PB_GunsmithWorkshop1,
            Entities.PB_GunsmithWorkshop2,
        },
        {
            Entities.PB_Sawmill1,
            Entities.PB_Sawmill2,
        },
        {
            Entities.PB_StoneMason1,
            Entities.PB_StoneMason2,
        },
    }
    for _,v in ipairs(refinebuildings) do
        local refinevalue = math.random(3,5)
        for _,refinebuilding in ipairs(v) do
            CLogic.SetRefinedResourcesValue(refinebuilding, refinevalue)
            refinevalue = refinevalue + math.random(0,2)

            local refinetype = GetEntityTypeBehaviorProperties(refinebuilding, 7818276)[4]
            refinetype:SetInt(RandomChaos.ResourceTypes[refinetype:GetInt()] or refinetype:GetInt())
        end
    end

    local resourceentities = {
        Entities.XD_ClayPit1,
        Entities.XD_Clay1,
        Entities.XD_StonePit1,
        Entities.XD_Stone1,
        Entities.XD_IronPit1,
        Entities.XD_Iron1,
        Entities.XD_SulfurPit1,
        Entities.XD_Sulfur1,
        Entities.XD_ResourceTree,
    }
    for _,resourceentity in pairs(resourceentities) do
        CLogic.SetSerfExtractionAmount(Entities.PU_Serf, resourceentity, math.random(1,2))
        CLogic.SetSerfExtractionTime(Entities.PU_Serf, resourceentity, math.random(3,9))
    end

    local workers = {
        Entities.PU_Alchemist,
        Entities.PU_BrickMaker,
        Entities.PU_Gunsmith,
        Entities.PU_Sawmillworker,
        Entities.PU_Smith,
        Entities.PU_Stonecutter,
        Entities.PU_Treasurer,
    }
    for _, worker in pairs(workers) do
        local workerbehavior = GetEntityTypeBehaviorProperties(worker, 7809936)
        workerbehavior[27]:SetInt(RandomChaos.RawResourceTypes[workerbehavior[27]:GetInt()])
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupSerfMenu()
    -- shuffle buildings
    RandomChaos.BuildingUpgradeCategories = {}
    RandomChaos.BuildingTechnologies = {}
    local lut = {
        GenericBridge = "Bridge",
        GenericMine = "Claymine",
        Stable = "Stables",
        VillageCenter = "Village",
    }
    local keys = {
        ["Alchemist"] = 0,
        ["Archery"] = 0,
        ["Bank"] = 0,
        ["Barracks"] = 0,
        ["Beautification01"] = 0,
        ["Beautification02"] = 0,
        ["Beautification03"] = 0,
        ["Beautification04"] = 0,
        ["Beautification05"] = 0,
        ["Beautification06"] = 0,
        ["Beautification07"] = 0,
        ["Beautification08"] = 0,
        ["Beautification09"] = 0,
        ["Beautification10"] = 0,
        ["Beautification11"] = 0,
        ["Beautification12"] = 0,
        ["Blacksmith"] = 0,
        ["Brickworks"] = 0,
        ["Farm"] = 0,
        ["Foundry"] = 0,
        ["GenericBridge"] = 0,
        ["GenericMine"] = 0,
        ["GunsmithWorkshop"] = 0,
        ["Market"] = 0,
        ["MasterBuilderWorkshop"] = 0,
        ["Monastery"] = 0,
        ["PowerPlant"] = 0,
        ["Residence"] = 0,
        ["Sawmill"] = 0,
        ["Stable"] = 0,
        ["StoneMason"] = 0,
        ["Tavern"] = 0,
        ["Tower"] = 0,
        ["University"] = 0,
        ["VillageCenter"] = 0,
        ["Weathermachine"] = 0,
    }
    local buildingupgradecategories = {}
    local buildingtechnologies = {}
    local upgradecategorytotechnology = {}
    for k,_ in pairs(keys) do
        RandomChaos.BuildingUpgradeCategories[UpgradeCategories[k]] = 0
        table.insert(buildingupgradecategories, UpgradeCategories[k])

        RandomChaos.BuildingTechnologies[Technologies["B_"..(lut[k] or k)]] = 0
        table.insert(buildingtechnologies, Technologies["B_"..(lut[k] or k)])

        upgradecategorytotechnology[UpgradeCategories[k]] = Technologies["B_"..(lut[k] or k)]
    end
    for upgradecategory,_ in pairs(RandomChaos.BuildingUpgradeCategories) do
        local index = math.random(table.getn(buildingupgradecategories))
        RandomChaos.BuildingUpgradeCategories[upgradecategory] = buildingupgradecategories[index]
        RandomChaos.BuildingTechnologies[upgradecategorytotechnology[upgradecategory]] = buildingtechnologies[index]
        table.remove(buildingupgradecategories, index)
        table.remove(buildingtechnologies, index)
    end

    RandomChaos.GUIAction_PlaceBuilding = GUIAction_PlaceBuilding
    function GUIAction_PlaceBuilding(_UpgradeCategory)
        RandomChaos.GUIAction_PlaceBuilding(RandomChaos.BuildingUpgradeCategories[_UpgradeCategory])
    end

    RandomChaos.GUIUpdate_BuildingButtons = GUIUpdate_BuildingButtons
    function GUIUpdate_BuildingButtons(_Button, _Technology)
        RandomChaos.GUIUpdate_BuildingButtons(_Button, RandomChaos.BuildingTechnologies[_Technology] or _Technology)
    end

    RandomChaos.GUIUpdate_UpgradeButtons = GUIUpdate_UpgradeButtons
    function GUIUpdate_UpgradeButtons(_Button, _Technology)
        RandomChaos.GUIUpdate_UpgradeButtons(_Button, RandomChaos.BuildingTechnologies[_Technology] or _Technology)
    end

    RandomChaos.GUITooltip_ConstructBuilding = GUITooltip_ConstructBuilding
    function GUITooltip_ConstructBuilding(_UpgradeCategory, _NormalTooltip, _DiabledTooltip,_TechnologyType, _ShortCut)
        RandomChaos.GUITooltip_ConstructBuilding(RandomChaos.BuildingUpgradeCategories[_UpgradeCategory] or _UpgradeCategory, _NormalTooltip, _DiabledTooltip,_TechnologyType, _ShortCut)
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupMotivationBuildings()
    
    local motivationbuildings = {
        Entities.PB_Beautification01,
        Entities.PB_Beautification02,
        Entities.PB_Beautification03,
        Entities.PB_Beautification04,
        Entities.PB_Beautification05,
        Entities.PB_Beautification06,
        Entities.PB_Beautification07,
        Entities.PB_Beautification08,
        Entities.PB_Beautification09,
        Entities.PB_Beautification10,
        Entities.PB_Beautification11,
        Entities.PB_Beautification12,
    }
    for _, entitytype in pairs(motivationbuildings) do
        GetEntityTypeBehaviorProperties(entitytype, 7836116)[4]:SetFloat(math.random(2,8)/100)
    end

    local amount = 0
    for i = 1,3 do
        amount = amount + math.random(5,10)/100
        GetEntityTypeBehaviorProperties(Entities["PB_Monastery"..i], 7836116)[4]:SetFloat(amount)
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupTrading()

    function GUAction_MarketAcceptDeal(_SellResourceType)
        
        -- swap buy and sell resource
        local SellResourceType, SellAmount = InterfaceTool_MarketGetBuyResourceTypeAndAmount()
        local Costs = {}
        
        Costs[SellResourceType] = SellAmount
        
        if InterfaceTool_HasPlayerEnoughResources_Feedback( Costs ) == 1 then
            local resourcetypes = {
                ResourceType.Gold,
                ResourceType.Clay,
                ResourceType.Wood,
                ResourceType.Stone,
                ResourceType.Iron,
                ResourceType.Sulfur,
            }
            
            local BuildingID = GUI.GetSelectedEntity()
            local BuyResourceType = resourcetypes[GetRandom_Client(1, table.getn(resourcetypes))]
            local BuyResourceAmount = GetBuyResourceAmount(GUI.GetPlayerID(), SellResourceType, SellAmount, BuyResourceType)
            
            GUI.StartTransaction(BuildingID, SellResourceType, BuyResourceType, BuyResourceAmount)
            XGUIEng.ShowWidget(gvGUI_WidgetID.TradeInProgress,1)
        end	
    end

    function GetBuyResourceAmount(_PlayerId, _SellResourceType, _SellResourceAmount, _BuyResourceType)
        return _SellResourceAmount * Logic.GetCurrentPrice(_PlayerId, _SellResourceType) / Logic.GetCurrentPrice(_PlayerId, _BuyResourceType)
    end
end 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupTaxes()
    local gamelogicobject = CUtilMemory.GetMemory(tonumber("85A3E0", 16))[0]
    local startadress = gamelogicobject[11]
    local endadress = gamelogicobject[12]
    local lastindex = (endadress:GetInt() - startadress:GetInt()) / 4 - 1

    local taxamount, motivationchange
    for i = 0, lastindex, 3 do
        taxamount, motivationchange = math.random(0,20), math.random(-20,20) / 100
        startadress[i + 1]:SetInt(taxamount)
        if i ~= 6 then
            startadress[i + 2]:SetFloat(motivationchange)
        end
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupHeroes()

    RandomChaos.HeroTable = {}
    RandomChaos.HeroTypes = {
        Entities.PU_Hero1c,
        Entities.PU_Hero2,
        Entities.PU_Hero3,
        Entities.PU_Hero4,
        Entities.PU_Hero5,
        Entities.PU_Hero6,
        Entities.CU_BlackKnight,
        Entities.CU_Mary_de_Mortfichet,
        Entities.CU_Barbarian_Hero,
        Entities.PU_Hero10,
        Entities.PU_Hero11,
        Entities.CU_Evil_Queen,
    }

    function RandomChaos_HeroCreated()
        local id = Event.GetEntityID()
        if Logic.IsHero(id) == 1 then
            table.insert(RandomChaos.HeroTable, id)
        end
    end

    function RandomChaos_HeroDiedJob()
        for i = table.getn(RandomChaos.HeroTable), 1, -1 do
            local id = RandomChaos.HeroTable[i]
            if not Logic.IsEntityAlive(id) then
                local player = Logic.EntityGetPlayer(id)
                Logic.DestroyEntity(id)
                Logic.SetNumberOfBuyableHerosForPlayer(player, Logic.GetNumberOfBuyableHerosForPlayer(player) + 1)
                table.remove(RandomChaos.HeroTable, i)
            end
        end
    end

    RandomChaos.BuyHeroWindow_Action_BuyHero = BuyHeroWindow_Action_BuyHero
    function BuyHeroWindow_Action_BuyHero(_herotype)
        RandomChaos.BuyHeroWindow_Action_BuyHero(RandomChaos.HeroTypes[GetRandom_Client(1, table.getn(RandomChaos.HeroTypes))])
    end

    Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, "RandomChaos_HeroCreated", 1, nil, nil)
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "RandomChaos_HeroDiedJob", 1, nil, nil)
end 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupBlessSettlers()
    RandomChaos.GUIAction_BlessSettlers = GUIAction_BlessSettlers
    function GUIAction_BlessSettlers(_BlessCategory)
        if _BlessCategory < 3 then
            _BlessCategory = GetRandom_Client(1, 2)
        elseif _BlessCategory < 5 then
            _BlessCategory = GetRandom_Client(1, 4)
        else
            _BlessCategory = GetRandom_Client(1, 5)
        end
        RandomChaos.GUIAction_BlessSettlers(_BlessCategory)
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupWeatherChange()
    RandomChaos.GUIAction_ChangeWeather = GUIAction_ChangeWeather
    function GUIAction_ChangeWeather(_WeatherType)
        RandomChaos.GUIAction_ChangeWeather(GetRandom_Client(1, 3))
    end
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function RandomChaos.SetupLogic()
    local gamelogicobject = CUtilMemory.GetMemory(tonumber("85A3E0", 16))[0]

    -- winter
    gamelogicobject[25]:SetFloat(math.random(60,120)/100)
    gamelogicobject[26]:SetFloat(math.random(60,120)/100)
    gamelogicobject[27]:SetFloat(math.random(60,120)/100)
    --rain
    gamelogicobject[28]:SetFloat(math.random(60,120)/100)
    gamelogicobject[29]:SetFloat(math.random(60,120)/100)
    gamelogicobject[30]:SetFloat(math.random(60,120)/100)
    -- misschance
    gamelogicobject[31]:SetInt(math.random(0,10))
    gamelogicobject[32]:SetInt(math.random(0,10))
end
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- adds a unique value at the end of given table
---@param _table table
---@param _value any
function table.addunique(_table, _value)
    for _,v in pairs(_table) do
        if v == _value then
            return
        end
    end
    table.insert(_table, _value)
end
---------------------------------------------------------------------------------------------------------------------
function GetEntityTypeBehaviorProperties( _EntityType, _Behavior )
	
	if _EntityType ~= 0 then
		
		local entitytypeadress = CUtilMemory.GetMemory( 9002416 )[ 0 ][ 7 ][ _EntityType ]
		
		local startadress = entitytypeadress[ 26 ]
		local endadress = entitytypeadress[ 27 ]
		local lastindex = ( endadress:GetInt() - startadress:GetInt() ) / 4 - 1
		
		for i = 0, lastindex do
			
			local behavioraddress = startadress[ i ]
			
			if behavioraddress:GetInt() ~= 0 and behavioraddress[ 0 ]:GetInt() == _Behavior then
				return behavioraddress
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------
function GetRandom_Client(_Min, _Max)
    return GetRandom_Internal(0, _Min, _Max)
end
---------------------------------------------------------------------------------------------------------------------
function GetRandom_Sync(_Min, _Max)
    return GetRandom_Internal(1, _Min, _Max)
end
---------------------------------------------------------------------------------------------------------------------
function GetRandom_Internal(_Method, _Min, _Max)
    local min = (_Max and _Min) or 0
    local max = _Max or _Min or 1
    return (_Method == 1 and Logic.GetRandom(max - min + 1) + min) or XGUIEng.GetRandom(max - min) + min
end