local OnInitialize
local OnMapStart

RandomChaos = {}

function OnInitialize()
	CWidget.Transaction_AddRawWidgetsFromFile("CSinglePlayer\\Mods\\RandomChaos\\SP_RCButton.xml")

    RandomChaos.StartMap = Framework.StartMap
    Framework.StartMap = function(_MapName, _MapType, _CampaignName)
        OnMapStart()
        RandomChaos.StartMap(_MapName, _MapType, _CampaignName)
    end
end

function OnMapStart()
	
	if RandomChaos.IsActive then
		CMod.PushArchiveRelative("CSinglePlayer\\Mods\\RandomChaos\\RandomChaos.bba")

		local settlerupgrades = {
			[[<SettlerUpgrade>
				<Category>LeaderBow2</Category>
				<FirstSettler>PU_LeaderBow2</FirstSettler>
			</SettlerUpgrade>]],
			
			[[<SettlerUpgrade>
				<Category>SoldierBow2</Category>
				<FirstSettler>PU_SoldierBow2</FirstSettler>
			</SettlerUpgrade>]],
			
			[[<SettlerUpgrade>
				<Category>LeaderBow3</Category>
				<FirstSettler>PU_LeaderBow3</FirstSettler>
			</SettlerUpgrade>]],
			
			[[<SettlerUpgrade>
				<Category>SoldierBow3</Category>
				<FirstSettler>PU_SoldierBow3</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderBow4</Category>
				<FirstSettler>PU_LeaderBow4</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierBow4</Category>
				<FirstSettler>PU_SoldierBow4</FirstSettler>
			</SettlerUpgrade>]],
			
			[[<SettlerUpgrade>
				<Category>LeaderCavalry2</Category>
				<FirstSettler>PU_LeaderCavalry2</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierCavalry2</Category>
				<FirstSettler>PU_SoldierCavalry2</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderHeavyCavalry2</Category>
				<FirstSettler>PU_LeaderHeavyCavalry2</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierHeavyCavalry2</Category>
				<FirstSettler>PU_SoldierHeavyCavalry2</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderPoleArm2</Category>
				<FirstSettler>PU_LeaderPoleArm2</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierPoleArm2</Category>
				<FirstSettler>PU_SoldierPoleArm2</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderPoleArm3</Category>
				<FirstSettler>PU_LeaderPoleArm3</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierPoleArm3</Category>
				<FirstSettler>PU_SoldierPoleArm3</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderPoleArm4</Category>
				<FirstSettler>PU_LeaderPoleArm4</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierPoleArm4</Category>
				<FirstSettler>PU_SoldierPoleArm4</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderRifle2</Category>
				<FirstSettler>PU_LeaderRifle2</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierRifle2</Category>
				<FirstSettler>PU_SoldierRifle2</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderSword2</Category>
				<FirstSettler>PU_LeaderSword2</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierSword2</Category>
				<FirstSettler>PU_SoldierSword2</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderSword3</Category>
				<FirstSettler>PU_LeaderSword3</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierSword3</Category>
				<FirstSettler>PU_SoldierSword3</FirstSettler>
			</SettlerUpgrade>]],

			[[<SettlerUpgrade>
				<Category>LeaderSword4</Category>
				<FirstSettler>PU_LeaderSword4</FirstSettler>
			</SettlerUpgrade>]],
		
			[[<SettlerUpgrade>
				<Category>SoldierSword4</Category>
				<FirstSettler>PU_SoldierSword4</FirstSettler>
			</SettlerUpgrade>]],
		}
		
		for _, settlerupgrade in pairs ( settlerupgrades ) do
			CMod.AppendToXML("data\\config\\logic.xml", settlerupgrade)
		end
	end
end

function SP_Menu.ToggleRC()
	if RandomChaos.IsActive then
		RandomChaos.IsActive = false
	else
		RandomChaos.IsActive = true
	end
end

function SP_Menu.UpdateRC()
	if RandomChaos.IsActive then
		XGUIEng.HighLightButton( XGUIEng.GetCurrentWidgetID(), 1 )
	else
		XGUIEng.HighLightButton( XGUIEng.GetCurrentWidgetID(), 0 )
	end
end

local Callbacks = {
		
    OnInitialize = OnInitialize,
    OnMapStart = OnMapStart,
    
    -- Metadata
    Name = "RandomChaos",
}

ModLoader_Register( Callbacks )