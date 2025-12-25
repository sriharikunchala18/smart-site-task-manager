const express = require('express');
const Joi = require('joi');
const { v4: uuidv4 } = require('uuid');
const { classifyTask } = require('../utils/classification');
const supabase = require('../config/supabase');

const router = express.Router();

// Validation schemas
const createTaskSchema = Joi.object({
  title: Joi.string().required(),
  description: Joi.string().required(),
  assigned_to: Joi.string().optional(),
  due_date: Joi.date().optional()
});

const updateTaskSchema = Joi.object({
  title: Joi.string().optional(),
  description: Joi.string().optional(),
  category: Joi.string().valid('scheduling', 'finance', 'technical', 'safety', 'general').optional(),
  priority: Joi.string().valid('high', 'medium', 'low').optional(),
  status: Joi.string().valid('pending', 'in_progress', 'completed').optional(),
  assigned_to: Joi.string().optional(),
  due_date: Joi.date().optional()
});

const idSchema = Joi.string().uuid().required();



// POST /api/tasks - Create a new task
router.post('/', async (req, res) => {
  try {
    const { error, value } = createTaskSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { title, description, assigned_to, due_date } = value;

    // Classify the task
    const classification = classifyTask(title, description);

    const taskData = {
      id: uuidv4(),
      title,
      description,
      category: classification.category,
      priority: classification.priority,
      status: 'pending',
      assigned_to: assigned_to || null,
      due_date: due_date ? new Date(due_date).toISOString() : null,
      extracted_entities: classification.extracted_entities,
      suggested_actions: classification.suggested_actions,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    let createdTask;

    if (useSupabase) {
      // Insert into Supabase
      const { data, error: insertError } = await supabase
        .from('tasks')
        .insert([taskData])
        .select();

      if (insertError) {
        console.error('Supabase insert error:', insertError);
        // Fallback to in-memory storage
        tasks.push(taskData);
        createdTask = taskData;
      } else {
        createdTask = data[0];
        // Log to task history
        await supabase
          .from('task_history')
          .insert([{
            task_id: taskData.id,
            action: 'created',
            old_value: null,
            new_value: taskData,
            changed_by: assigned_to || 'system',
            changed_at: new Date().toISOString()
          }]).catch(() => {}); // Ignore history logging errors
      }
    } else {
      // Use in-memory storage
      tasks.push(taskData);
      createdTask = taskData;
    }

    res.status(201).json(createdTask);
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// GET /api/tasks - List all tasks with filters
router.get('/', async (req, res) => {
  try {
    const { status, category, priority, limit = 10, offset = 0 } = req.query;

    let query = supabase
      .from('tasks')
      .select('*')
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (status) query = query.eq('status', status);
    if (category) query = query.eq('category', category);
    if (priority) query = query.eq('priority', priority);

    const { data, error } = await query;

    if (error) {
      console.error('Supabase query error:', error);
      return res.status(500).json({ error: 'Failed to fetch tasks' });
    }

    res.json(data);
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// GET /api/tasks/:id - Get task details
router.get('/:id', async (req, res) => {
  try {
    const { error: idError } = idSchema.validate(req.params.id);
    if (idError) {
      return res.status(400).json({ error: 'Invalid task ID' });
    }

    const { id } = req.params;

    if (useSupabase) {
      const { data, error } = await supabase
        .from('tasks')
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') {
          // Fallback to in-memory storage
          const task = tasks.find(t => t.id === id);
          if (!task) {
            return res.status(404).json({ error: 'Task not found' });
          }
          return res.json(task);
        }
        console.error('Supabase query error:', error);
        return res.status(500).json({ error: 'Failed to fetch task' });
      }

      return res.json(data);
    } else {
      // Use in-memory storage
      const task = tasks.find(t => t.id === id);
      if (!task) {
        return res.status(404).json({ error: 'Task not found' });
      }
      return res.json(task);
    }
  } catch (error) {
    console.error('Error fetching task:', error);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

// PATCH /api/tasks/:id - Update task
router.patch('/:id', async (req, res) => {
  try {
    const { error: idError } = idSchema.validate(req.params.id);
    if (idError) {
      return res.status(400).json({ error: 'Invalid task ID' });
    }

    const { error, value } = updateTaskSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { id } = req.params;

    if (useSupabase) {
      // Get current task data for history
      const { data: currentTask, error: fetchError } = await supabase
        .from('tasks')
        .select('*')
        .eq('id', id)
        .single();

      if (fetchError) {
        if (fetchError.code === 'PGRST116') {
          // Fallback to in-memory storage
          const taskIndex = tasks.findIndex(t => t.id === id);
          if (taskIndex === -1) {
            return res.status(404).json({ error: 'Task not found' });
          }
          const updateData = {
            ...value,
            updated_at: new Date().toISOString()
          };
          tasks[taskIndex] = { ...tasks[taskIndex], ...updateData };
          return res.json(tasks[taskIndex]);
        }
        console.error('Supabase fetch error:', fetchError);
        return res.status(500).json({ error: 'Failed to update task' });
      }

      const updateData = {
        ...value,
        updated_at: new Date().toISOString()
      };

      const { data, error: updateError } = await supabase
        .from('tasks')
        .update(updateData)
        .eq('id', id)
        .select();

      if (updateError) {
        console.error('Supabase update error:', updateError);
        return res.status(500).json({ error: 'Failed to update task' });
      }

      // Log to task history
      await supabase
        .from('task_history')
        .insert([{
          task_id: id,
          action: 'updated',
          old_value: currentTask,
          new_value: data[0],
          changed_by: 'system',
          changed_at: new Date().toISOString()
        }]).catch(() => {}); // Ignore history logging errors

      return res.json(data[0]);
    } else {
      // Use in-memory storage
      const taskIndex = tasks.findIndex(t => t.id === id);
      if (taskIndex === -1) {
        return res.status(404).json({ error: 'Task not found' });
      }
      const updateData = {
        ...value,
        updated_at: new Date().toISOString()
      };
      tasks[taskIndex] = { ...tasks[taskIndex], ...updateData };
      return res.json(tasks[taskIndex]);
    }
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// DELETE /api/tasks/:id - Delete task
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    if (useSupabase) {
      // Get current task data for history before deletion
      const { data: currentTask, error: fetchError } = await supabase
        .from('tasks')
        .select('*')
        .eq('id', id)
        .single();

      if (fetchError) {
        if (fetchError.code === 'PGRST116') {
          // Fallback to in-memory storage
          const taskIndex = tasks.findIndex(t => t.id === id);
          if (taskIndex === -1) {
            return res.status(404).json({ error: 'Task not found' });
          }
          tasks.splice(taskIndex, 1);
          return res.status(204).send();
        }
        console.error('Supabase fetch error:', fetchError);
        return res.status(500).json({ error: 'Failed to delete task' });
      }

      const { error: deleteError } = await supabase
        .from('tasks')
        .delete()
        .eq('id', id);

      if (deleteError) {
        console.error('Supabase delete error:', deleteError);
        return res.status(500).json({ error: 'Failed to delete task' });
      }

      // Log to task history
      await supabase
        .from('task_history')
        .insert([{
          task_id: id,
          action: 'deleted',
          old_value: currentTask,
          new_value: null,
          changed_by: 'system',
          changed_at: new Date().toISOString()
        }]).catch(() => {}); // Ignore history logging errors

      return res.status(204).send();
    } else {
      // Use in-memory storage
      const taskIndex = tasks.findIndex(t => t.id === id);
      if (taskIndex === -1) {
        return res.status(404).json({ error: 'Task not found' });
      }
      tasks.splice(taskIndex, 1);
      return res.status(204).send();
    }
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

module.exports = router;
