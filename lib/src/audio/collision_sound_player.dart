import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';

class CollisionSoundPlayer {
  CollisionSoundPlayer({
    math.Random? random,
    List<AudioPlayer>? players,
    this._minimumIntervalSeconds = 0.09,
  }) : _random = random ?? math.Random(),
       _players = players ?? _createPlayers();

  static const _soundAssets = [
    'audio/collision_chime_1.wav',
    'audio/collision_chime_2.wav',
    'audio/collision_chime_3.wav',
    'audio/collision_chime_4.wav',
  ];

  final math.Random _random;
  final double _minimumIntervalSeconds;
  final List<AudioPlayer> _players;
  var _nextPlayerIndex = 0;
  var _lastPlayedAtSeconds = double.negativeInfinity;

  static List<AudioPlayer> _createPlayers() {
    return List.generate(4, (index) {
      return AudioPlayer(playerId: 'collision-sound-$index')
        ..setReleaseMode(ReleaseMode.stop);
    });
  }

  void playRandom(double elapsedSeconds) {
    if (elapsedSeconds - _lastPlayedAtSeconds < _minimumIntervalSeconds) {
      return;
    }

    _lastPlayedAtSeconds = elapsedSeconds;
    final player = _players[_nextPlayerIndex];
    _nextPlayerIndex = (_nextPlayerIndex + 1) % _players.length;
    final asset = _soundAssets[_random.nextInt(_soundAssets.length)];
    final volume = 0.26 + _random.nextDouble() * 0.12;

    unawaited(_restart(player, asset, volume));
  }

  Future<void> _restart(AudioPlayer player, String asset, double volume) async {
    await player.stop();
    await player.play(
      AssetSource(asset),
      volume: volume,
      mode: PlayerMode.lowLatency,
    );
  }

  Future<void> stop() async {
    _lastPlayedAtSeconds = double.negativeInfinity;
    _nextPlayerIndex = 0;
    await Future.wait(_players.map((player) => player.stop()));
  }

  Future<void> dispose() async {
    await Future.wait(_players.map((player) => player.dispose()));
  }
}
