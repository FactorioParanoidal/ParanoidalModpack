import json

MIN = 2
THRESHOLD = 6
MAX = 42

def get_entity_migrations(chest_names):
    entities = []
    for old_type, new_name in chest_names.items():
        entities.extend(
            [
                f'wide-{old_type}-chest-{length}',
                f'WideChests_wide-{new_name}-{length}'
            ]
            for length in range(MIN, MAX + 1)
        )

        entities.extend(
            [
                f'high-{old_type}-chest-{length}',
                f'WideChests_high-{new_name}-{length}'
            ]
            for length in range(MIN, MAX + 1)
        )

        entities.extend(
            [
                f'{old_type}-warehouse-{width}x{height}',
                f'WideChests_{new_name}-warehouse-{width}x{height}'
            ]
            for width in range(MIN, MAX + 1)
            for height in range(MIN, MAX + 1)
            if width < THRESHOLD or height < THRESHOLD
        )
        
        entities.extend(
            [
                f'{old_type}-trashdump-{width}x{height}',
                f'WideChests_{new_name}-trashdump-{width}x{height}'
            ]
            for width in range(THRESHOLD, MAX + 1)
            for height in range(THRESHOLD, MAX + 1)
        )

    return entities

with open('WideChests_5.0.0.json', 'w+') as f:
    chest_names = {
        'wooden': 'wooden-chest',
        'iron': 'iron-chest',
        'steel': 'steel-chest'
    }

    json.dump({
        'item': [
            [
                'merge-chest-selector',
                'WideChests_merge-chest-selector'
            ]
        ],
        'entity': get_entity_migrations(chest_names)
    }, f)

with open('WideChestsLogistic_2.0.0.json', 'w+') as f:
    chest_names = {
        'logistic-passive': 'logistic-chest-passive-provider',
        'logistic-active': 'logistic-chest-active-provider',
        'logistic-storage': 'logistic-chest-storage',
        'logistic-buffer': 'logistic-chest-buffer',
        'logistic-requester': 'logistic-chest-requester',
    }

    json.dump({
        'entity': get_entity_migrations(chest_names)
    }, f)

with open('WideChestsBobs_1.0.0.json', 'w+') as f:
    chest_names = {
        'bob-brass': 'brass-chest',
        'bob-titanium': 'titanium-chest'
    }

    json.dump({
        'entity': get_entity_migrations(chest_names)
    }, f)

with open('WideChestsNullius_1.0.0.json', 'w+') as f:
    chest_names = {
        'nullius-small-1': 'wooden-chest',
        'nullius-small-2': 'iron-chest',
        'nullius-small-3': 'steel-chest',

        'nullius-small-logistic-passive-1': 'nullius-small-supply-chest-1',
        'nullius-small-logistic-passive-2': 'logistic-chest-passive-provider',
        'nullius-small-logistic-active-1': 'nullius-small-dispatch-chest-1',
        'nullius-small-logistic-active-2': 'logistic-chest-active-provider',
        'nullius-small-logistic-storage-1': 'nullius-small-storage-chest-1',
        'nullius-small-logistic-storage-2': 'logistic-chest-storage',
        'nullius-small-logistic-buffer-1': 'nullius-small-buffer-chest-1',
        'nullius-small-logistic-buffer-2': 'logistic-chest-buffer',
        'nullius-small-logistic-requester-1': 'nullius-small-demand-chest-1',
        'nullius-small-logistic-requester-2': 'logistic-chest-requester'
    }

    json.dump({
        'entity': get_entity_migrations(chest_names)
    }, f)

with open('WideChestsPaperChest_1.0.0.json', 'w+') as f:
    chest_names = {
        'paper-chest-cellulose-fiber': 'cellulose-fiber-chest',
        'paper-chest-paper': 'paper-chest'
    }

    json.dump({
        'entity': get_entity_migrations(chest_names)
    }, f)

with open('WideChestsVerySmallChests_1.0.0.json', 'w+') as f:
    chest_names = {
        'verysmallchests-wooden-chest-small': 'wooden-chest-small',
        'verysmallchests-iron-chest-small': 'iron-chest-small',
        'verysmallchests-steel-chest-small': 'steel-chest-small',

        'verysmallchests-logistic-passive-small': 'logistic-chest-passive-provider-small',
        'verysmallchests-logistic-active-small': 'logistic-chest-active-provider-small',
        'verysmallchests-logistic-storage-small': 'logistic-chest-storage-small',
        'verysmallchests-logistic-buffer-small': 'logistic-chest-buffer-small',
        'verysmallchests-logistic-requester-small': 'logistic-chest-requester-small',
    }

    json.dump({
        'entity': get_entity_migrations(chest_names)
    }, f)
