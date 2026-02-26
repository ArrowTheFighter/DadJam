extends Node

signal on_score_updated(score : int)

var shipped_items : int = 0
var shipping_prefrences =     [
        QualityEnum.Property.ROASTED,
        QualityEnum.Property.SMOOTH,
        QualityEnum.Property.CHILLED,
        QualityEnum.Property.CREAMY,
        QualityEnum.Property.SWEET
    ]

func ship_item(pickup : Pickup):
    shipped_items += 1
    var item_score = calculate_shipped_score(pickup)
    print("shipping item with score of " + str(item_score))
    print("total shipped items = " + str(shipped_items))
    on_score_updated.emit(item_score)
    pass


func calculate_shipped_score(pickup : Pickup) -> int:
    var score = 1
    if pickup.item_qualities.has(QualityEnum.Property.BOXED):
        score += 3
    for quality in pickup.item_qualities:
        print(QualityEnum.Property.keys()[quality])
    for prefrence in shipping_prefrences:
        if pickup.item_qualities.has(prefrence):
            score += 1
            
    return score
