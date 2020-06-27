import Vue from 'vue'
import Router from 'vue-router'
import AutionDetail from "../component/AutionDetail.vue"
import AutionTable from "../component/AutionTable.vue"
import AuctionWithLowValue from "../component/AuctionWithLowValue.vue"
import AuctionLowValueDetail from "../component/AuctionLowValueDetail.vue"
import AuctionCreation from "../component/AuctionCreation.vue"

Vue.use(Router)

export default new Router({
    routes: [
        {
            path: '/',
            name: 'aution-list',
            component: AutionTable
        },
        {
            path: '/autions/:autionId',
            name: 'aution-detail',
            component: AutionDetail
        },
        {
            path: '/auctions-with-low-value',
            name: 'auction-low-list',
            component: AuctionWithLowValue
        },
        {
            path: '/auctions-with-low-value/:auctionId',
            name: 'auction-low-value-detail',
            component: AuctionLowValueDetail
        },
        {
            path: '/create-auction',
            name: 'create-auction',
            component: AuctionCreation
        }


    ]
})