==========
References
==========

.. contents:: Table of Contents
    :depth: 2


--------------------


:guilabel:`GameEvent`
=====================

- **Inherits:** `Node <https://docs.godotengine.org/en/stable/classes/class_node.html>`_
- **Inherited by:** None
- **Singleton**

This class contains global signals that can be emitted and connected by any node.


+------------------------------+---------+
| Signals                      | Methods |
+==============================+=========+
|| :term:`player_connected`    ||        |
|| :term:`player_disconnected` ||        |
|| :term:`player_appended`     ||        |
|| :term:`player_erased`       ||        |
|| :term:`increase_score`      ||        |
|| :term:`round_setup`         ||        |
|| :term:`CTF_capture_flag`    ||        |
|| :term:`CTF_return_flag`     ||        |
|| :term:`CTF_drop_flag`       ||        |
+------------------------------+---------+


.. topic:: Signals

    .. glossary::
        player_connected
            Emitted right after a player connects.

            **Parameters**

            - player_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)
            - team_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        player_disconnected
            Emitted right before a player disconnects.

            **Parameters**

            - player_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        player_appended
            Emitted right after a player is appended.

            **Parameters**

            - player_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)
            - team_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        player_erased
            Emitted right before a player is erased.

            **Parameters**

            - player_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        increase_score
            Emitted when a team scores.

            **Parameters**

            - team_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)
            - score (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        round_setup
            Emitted when a round is set up.

            **Parameters**

            - winning_score (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

	CTF_capture_flag
            [CTF] Emitted when a team captures the enemy team's flag.

            **Parameters**

            - team_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        CTF_return_flag
            [CTF] Emitted when a flag is returned to its team's flag station.

            **Parameters**

            - team_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)

        CTF_drop_flag
            [CTF] Emitted when a team's flag is dropped.

            **Parameters**

            - team_id (`int <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#int>`_)
            - flag_global_position (`vector2 <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#vector2>`_)


--------------------


:guilabel:`NodeUtil`
====================

- **Inherits:** `Object <https://docs.godotengine.org/en/stable/classes/class_object.html>`_
- **Inherited by:** None

+------------+-------------------------+
| Attributes | Methods                 |
+============+=========================+
||           || :term:`play_animation` |
||           || :term:`reparent`       |
+------------+-------------------------+


.. topic:: Methods

    .. glossary::
        play_animation
            **Parameters**

            - AnimationPlayer\_ (`AnimationPlayer <https://docs.godotengine.org/en/stable/classes/class_animationplayer.html>`_
              or `AnimatedSprite <https://docs.godotengine.org/en/stable/classes/class_animatedsprite.html>`_)
            - animation (`string <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#string>`_) -
              The name of the animation.
            - replay (`bool <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#bool>`_) -
              If set to true, the current animation will be replayed if it is equal to the animation parameter.

            **Returns**

            void

        reparent
            **Parameters**

            - child (inherits `Node <https://docs.godotengine.org/en/stable/classes/class_node.html>`_)
            - new_parent (inherits `Node <https://docs.godotengine.org/en/stable/classes/class_node.html>`_)

            **Returns**

            void


--------------------


:guilabel:`MathUtil`
====================

- **Inherits:** `Reference <https://docs.godotengine.org/en/stable/classes/class_reference.html>`_
- **Inherited by:** None

+------------+----------------------------------+
| Attributes | Methods                          |
+============+==================================+
|            | :term:`calculate_pivot_rotation` |
+------------+----------------------------------+


.. topic:: Methods

    .. glossary::
        calculate_pivot_rotation
            Calculates the Pivot's rotation such that Origin's look vector points at Target's global_position.

            **Parameters**

            - Pivot (inherits `Node2D <https://docs.godotengine.org/en/stable/classes/class_node2d.html>`_) –
              The pivot and the object (as a child of the pivot) whose rotation is calculated.
            - Target (inherits `Node2D <https://docs.godotengine.org/en/stable/classes/class_node2d.html>`_) –
              The target that Origin's look vector wants to point at.
            - Origin (inherits `Node2D <https://docs.godotengine.org/en/stable/classes/class_node2d.html>`_) –
              The origin of the object whose rotation is calculated.

            .. note::

              Origin **must** be a direct child of Pivot.

            **Returns**

            The Pivot's rotation in radian.

            **Return type**

            `float <https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#float>`_


--------------------


:guilabel:`MapInfo`
===================

- **Inherits:** `Resource <https://docs.godotengine.org/en/stable/classes/class_resource.html>`_
- **Inherited by:** None

+--------------------+---------+
| Attributes         | Methods |
+====================+=========+
| CTF_flag_positions |         |
+--------------------+---------+


.. topic:: Attributes

    .. glossary::
        CTF_flag_positions
            [CTF] The positions of flag stations.

            **Type**

            Array(`Vector2 <https://docs.godotengine.org/en/stable/classes/class_vector2.html>`_)
