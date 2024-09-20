##todoService.ts:

import axios from 'axios';

const API_URL = 'https://jsonplaceholder.typicode.com/todos';

/**
 * Fetches todos from the API with pagination.
 *
 * @param limit - The number of todos to fetch per page.
 * @param page - The current page number.
 * @returns A Promise that resolves to an array of todos.
 */
export const fetchTodos = async (limit: number, page: number) => {
  try {
    const response = await axios.get(`${API_URL}?_limit=${limit}&_page=${page}`);
    return response.data;
  } catch (error) {
    throw new Error('Failed to fetch todos');
  }
};

## TodoTable.tsx:

import React, { useEffect, useState } from 'react';
import { fetchTodos } from './todoService';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, TablePagination, Typography } from '@mui/material';

interface Todo {
  userId: number;
  id: number;
  title: string;
  completed: boolean;
}

const TodoTable: React.FC = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [page, setPage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [error, setError] = useState<string | null>(null);
  const [totalCount, setTotalCount] = useState<number>(0); // Store the total count

  useEffect(() => {
    const getTodos = async () => {
      try {
        const data = await fetchTodos(rowsPerPage, page);
        setTodos(data);
        setError(null); // Reset error on successful fetch

        // Estimate the total count based on the fetched data and page information
        const estimatedTotalCount = data.length * page;
        setTotalCount(estimatedTotalCount);
      } catch (error) {
        setError(error.message);
      }
    };

    getTodos();
  }, [page, rowsPerPage]); // Fetch new data when page or rowsPerPage changes

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(1); // Reset to first page
  };

  return (
    <Paper>
      <Typography variant="h4" gutterBottom style={{ padding: '16px' }}>
        Todo List
      </Typography>
      {error ? (
        <Typography color="error" style={{ padding: '16px' }}>
          {error}
        </Typography>
      ) : (
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>ID</TableCell>
                <TableCell>Title</TableCell>
                <TableCell>Completed</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {todos.map((todo) => (
                <TableRow key={todo.id}>
                  <TableCell>{todo.id}</TableCell>
                  <TableCell>{todo.title}</TableCell>
                  <TableCell>{todo.completed ? 'Yes' : 'No'}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
      <TablePagination
        rowsPerPageOptions={[10, 20, 30, 40]}
        component="div"
        count={totalCount} // Use the estimated total count
        rowsPerPage={rowsPerPage}
        page={page - 1} // MUI Pagination expects zero-based index
        onPageChange={handleChangePage}
        onRowsPerPageChange={handleChangeRowsPerPage}
      />
    </Paper>
  );
};

export default TodoTable;

##App.tsx:

import React from 'react';
import TodoTable from './TodoTable';

const App: React.FC = () => {
  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '20px' }}>
      <TodoTable />
    </div>
  );
};

export default App;
