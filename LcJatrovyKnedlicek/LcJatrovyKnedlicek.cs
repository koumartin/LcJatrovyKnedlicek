using System.IO;
using System.Reflection;
using BepInEx;
using BepInEx.Logging;
using LcJatrovyKnedlicek;
using LethalLib.Modules;
using UnityEngine;

namespace LCJatrovyKnedlicek;

[BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
[BepInDependency(LethalLib.Plugin.ModGUID, BepInDependency.DependencyFlags.HardDependency)]
public class LcJatrovyKnedlicek : BaseUnityPlugin
{
    public static LcJatrovyKnedlicek Instance { get; private set; } = null!;
    internal new static ManualLogSource Logger { get; private set; } = null!;

    private static AssetBundle? _assetBundle;

    private void Awake()
    {
        Logger = base.Logger;
        Instance = this;

        // Init configs
        var rarityRegular = Config.Bind("General", "RarityRegularMoons", 80, "Rarity on regular moons.");
        var rarityDine = Config.Bind("General", "RarityDine", 5, "Rarity on Dine. (to not break its unique scrap design)");
        var rarityModded = Config.Bind("General", "RarityModded", 80, "Rarity of modded moons.");
        var minValue = Config.Bind("General", "MinValue", 24, "Minimum value for the scrap.");
        var maxValue = Config.Bind("General", "MaxValue", 60, "Maximum value for the scrap.");

        var assemblyLocation = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        Logger.LogInfo($"Loading custom assets from {assemblyLocation}");
        _assetBundle = AssetBundle.LoadFromFile(Path.Combine(assemblyLocation, "jatrovyknedlicek"));
        if (!_assetBundle) {
            Logger.LogError("Failed to load custom assets."); // ManualLogSource for your plugin
            return;
        }

        var item = _assetBundle.LoadAsset<Item>("Assets/Scrap/JatrovyKnedlicek/JatrovyKnedlicek.asset");
        item.minValue = (int)(minValue.Value / 0.4);
        item.maxValue = (int)(maxValue.Value / 0.4);
        Utilities.FixMixerGroups(item.spawnPrefab);
        NetworkPrefabs.RegisterNetworkPrefab(item.spawnPrefab);

        Items.RegisterScrap(item, rarityRegular.Value, Levels.LevelTypes.Vanilla  & ~Levels.LevelTypes.DineLevel);
        Items.RegisterScrap(item, rarityDine.Value, Levels.LevelTypes.DineLevel);
        Items.RegisterScrap(item, rarityModded.Value, Levels.LevelTypes.Modded);

        Logger.LogInfo($"{MyPluginInfo.PLUGIN_GUID} v{MyPluginInfo.PLUGIN_VERSION} has loaded!");
    }
}
