
local OnInitialize;
local OnMapStart;
local OnGameStarted;

local print = function(...)
	if LuaDebugger and LuaDebugger.Log then
		if table.getn(arg) > 1 then
			LuaDebugger.Log(arg)
		else
			LuaDebugger.Log(unpack(arg))
		end;
	end;
end;

function OnInitialize()
    print("RandomChaos OnInitialize");
	MetaMod.Register(
        "RandomChaos",
        {
            de="Random Chaos",
            en="Random Chaos"
        },
        {
            de="Features: @cr - beim Rekrutieren wird eine zufällige Militäreinheit ausgebildet @cr - alle Technologien sind zufällig vertauscht @cr - alle Technologien, Einheiten, Gebäude und Ausbauten kosten eine zufällige Anzahl und Typ an Rohstoffen @cr - Inhalt von Rohstoffvorkommen ist zufällig, Rohstofftyp ist vertauscht @cr - Abbaugeschwindigkeit und -menge von Leibeigenen, Minen und Veredlern ist zufällig @cr - Gebäude im Baumenü sind zufällig vertauscht @cr - Moti Gebäude geben zufälligen Bonus @cr - beim handeln bekommt man einen zufälligen Rohstoff @cr - Steuern und deren Wirkung auf die Motivation sind zufällig @cr - Helden kaufen, kauft einen zufälligen Helden. Wenn ein Held stirbt, ist er weg",
            en="Features: @cr - on recruitment a random military unit will be picked @cr - all technologies are shuffled @cr - every technology, unit, building and upgrad costs random resource types and amounts @cr - the resource amount in resource deposits is random and the resource types are shuffled @cr - extraction speed and amount of serfs, mines and refiners is random @cr - buildings in construction menu are shuffled @cr - motivation buildings give random bonuses @cr - tradings returns a random resource @cr - taxes and their effect on motivation are random @cr - buy hero buys a random hero. if a hero dies he is actually gone",
        },
        3
    );
end;
function OnMapStart()
	if MetaMod.IsActive("RandomChaos") then
		print("RandomChaos OnMapStart");
		CMod.PushArchiveRelative("MP_SettlerServer\\Mods\\RandomChaos\\RandomChaos.bba")

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
            CMod.AppendToXML("data\\config\\logic.xml", settlerupgrade);
        end
    end;
end;
function OnGameStarted()
	if MetaMod.IsActive("RandomChaos") then
		print("RandomChaos OnGameStarted");
		RandomChaos.InitAll();
	end;
end;

local Callbacks = {
	OnInitialize = OnInitialize;
	OnMapStart = OnMapStart;
	OnGameStarted = OnGameStarted;
	Name = "RandomChaos";
};
ModLoader_Register(Callbacks);