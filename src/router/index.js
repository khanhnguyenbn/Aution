import Vue from 'vue'
import Router from 'vue-router'
import AutionDetail from "../component/AutionDetail.vue"
import AutionTable from "../component/AutionTable.vue"

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
        }

    ]
})