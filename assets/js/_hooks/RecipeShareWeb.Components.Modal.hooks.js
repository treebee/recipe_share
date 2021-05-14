const Modal = {
    mounted() {
        window.modalHook = this
    },
    destroyed() {
        window.modalHook = null
    },
    modalClosing(leaveDuration, eventName) {
        setTimeout(() => {
            var selector = `#${this.el.id}`
            if (document.querySelector(selector)) {
                this.pushEventTo(selector, 'modal-closed', {})
            }
        }, leaveDuration)
    }
}

export { Modal }