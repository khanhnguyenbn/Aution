import Vue from 'vue'
import Router from 'vue-router'
import HelloWorld from "../component/HelloWorld.vue"

Vue.use(Router)

export default new Router({
    routes: [
        {
            path: '/',
            name: 'hello',
            component: HelloWorld
        }

    ]
})