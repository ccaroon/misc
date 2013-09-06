var cards = {

    armada_wurm: {
        name: "Armada Wurm",
        mana_cost: "BWG",
        main_type: "Creature",
        sub_type: "Wurm",
        foil: false,
        rarity: "Uncommon",
        count: Math.floor(Math.random()*11)
    },

    generate: function (count) {
        var cards = [],
            i     = 0;

        for (i = 0; i < count; i+=1) {
            cards.push({
                name: "Card #" + i,
                mana_cost: i,
                main_type: "Maintype(" + i + ")",
                sub_type: "Subtype(" + i + ")",
                foil: false,
                rarity: "Common",
                count: Math.floor(Math.random()*11)
            });
        }

        return (cards);
    }

};
module.exports = cards;
