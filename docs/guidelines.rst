Guidelines
==========

This is the general guideline for contributing to the :doc:`Everhunt <readme>` project.

.. contents:: Table of Contents


--------------------


Code structure
--------------

.. parsed-literal::

    root
    │    :term:`.gitignore`
    │    :term:`LICENSE.md`
    │    :term:`README.rst`
    |    :term:`project.godot`
    │
    ├─── :term:`addons`
    ├─── :term:`assets`
    │   ├─── :term:`images`
    │   ├─── :term:`sfx`
    │   ├─── :term:`sprites`
    │   └─── :term:`tileset`
    |
    ├─── :term:`docs`
    └─── :term:`src`
        │    :term:`main.tscn`
        │
        ├─── :term:`components`
        ├─── :term:`scenes`
        ├─── :term:`scripts`
        └─── :term:`utils`

.. glossary::

    .gitignore : file
        Containing files and directories ignored by git.

    LICENSE.md : file
        Containing license details of the game.

    README.rst : file
        Containing general information about the game.

    project.godot : file
        Project settings.

    addons : folder
        Containing Godot plugins.

    assets : folder
        Containing assets including images, sprites, sfx.

    images : folder
        Containing images that are not sprites such as logos, thumbnails, covers, etc.
    
    sfx : folder
        Containing sound and music files.

    sprites : folder
        Containing game sprites.

    tileset : folder
        Containing files relating to tileset such as .tres files.

    docs : folder
        Containing documentation files.
    
    src : folder
        Containing source code including scripts and scenes.

    main.tscn : file
        The master scene. In charge of switching between different scenes.

    components : folder
        Containing all component scenes and nodes ranging from player
        to abilities, particles, etc.

    scenes : folder
        Containing all primary scenes such as the HUD and match maps.

    scripts : folder
        Containing scripts controlling player, abilities, game logics, networking, etc.

    utils : folder
        Containing helper scripts and scenes shared between multiple components.


--------------------


Code Style
----------

Naming convention
^^^^^^^^^^^^^^^^^

Checkout out GDscript
`naming convention <https://docs.godotengine.org/en/stable/tutorials/shading/godot_shader_language_style_guide.html#naming-conventions>`_.

In short:

- Functions and variables: snake_case
- Classes: camelCase
- Constants: CONSTANT_CASE

Design pattern
^^^^^^^^^^^^^^

Check out some design patterns provided by **GDQuest**
`here <https://www.gdquest.com/tutorial/godot/design-patterns/intro-to-design-patterns/>`_.
Pay special attention to the
`Finite state machine pattern <https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/>`_.


--------------------


Bug report
----------

Requirements:

    1. Provide a list of actionable steps to reproduce the bug
    2. Provide the version of the project, of the program, e.g. Godot 3.1, and the operating system you are working with
    3. If the program prints an error in the console, copy it as text (preferable) or take a screenshot (optional)
    4. Tell us the expected result

Here an example of a good bug report:

.. parsed-literal::

    **Title**: Trimming video gives an error if time cursor doesn’t overlap any sequence

    **Program version**:
    - Power Sequencer 1.3
    - Blender 2.80 RC1

    **Steps to reproduce**:
    1. Place the time cursor so that it doesn’t overlap any sequence
    2. Press T to use the trim feature

    **Expected result**:
    No error

    **Traceback**:
    File "/home/gdquest/.config/blender/2.80/scripts/addons/power-sequencer/operators/trim_left_or_right_handles.py", line 63, in execute
    ripple_start_frame = min(sequences, key=attrgetter('frame_final_start')).frame_final_start
    ValueError: min() arg is an empty sequence


--------------------


Pull request and commit
-----------------------

Commit
^^^^^^

Every commit must have a meaningful commit message.
Here are a few guidelines:

    1. Separate subject from body with a blank line
    2. Start the subject line with a verb (Add, Fix, Change, etc)
    3. Keep the subject line under 50 characters
    4. Do not end the subject line with a period
    5. Use the imperative mood in the subject line
    6. Wrap the body at 72 characters
    7. Use the body to explain what, why and how

Some examples of good commit messages:

.. parsed-literal::

    **Add** life bars for the monsters 
    **Fix** the character getting stuck in the wall
    **Redesign** level 3
    **Improve** performances in the level loader class

.. note::

    Commit should be relatively small.
    If a commit is too large, try to split it into smaller commits where relevant.


Pull request
^^^^^^^^^^^^

Open a pull request at `PR <https://github.com/Legacy107/Everhunt/pulls/>`_

All pull requests must follow the below format:

    :Title:
        Title of the pull request must be short and start with the task or issue code
        (EH-x for task, #x for issue).

    :Description:
        Describe all changes that have been done in bullet list.
        Include screenshots and issue references if needed.

    :Tag:
        Attach the appropriate tag to the pull request from the tags list.

    :Review:
        All pull requests to merge into the main branch need at least 1 review.
        Remember to request reviewers when creating a new pull request.

.. note::

    Pull requests should be squashed before being merged so that the project’s history stays easy to browse.


--------------------


Art style
---------

**TODO**


