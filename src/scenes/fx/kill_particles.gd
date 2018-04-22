extends Timer


func kill_particles():
	get_parent().queue_free()
